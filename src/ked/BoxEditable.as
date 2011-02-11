// an editable box

package ked
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.*;
	
	import flash.display.Sprite;

    public class BoxEditable implements IEditable
    {
		private var m_editor:Editor;

        //  Box placement and dimensions
        public var X:Number;
        public var Y:Number;
        public var Width:Number;
        public var Height:Number;
        public var Angle:Number;

        //  Physics data
        private var m_body:b2Body;
        
        //  Selection highlighting
        private var m_selection:Sprite;        
        private var m_selected:Boolean = false;
        
        //  True if dynamic body, false if static body
        private var m_dynamicBody:Boolean;

        public function BoxEditable(editor:Editor,
								    x:Number, y:Number, 
                                    width:Number, height:Number,
                                    angle:Number,
                                    dynamicBody:Boolean)
        {
            m_editor = editor;
            m_body = null;

            //  Location in world coords
            MoveTo(x, y);

            //  Width and height in world units
            Width = width;
            Height = height;
            //  Orientation (rad)
            Angle = angle;
            
            //  Selection highlight
            m_selection = new Sprite();
            
            m_dynamicBody = dynamicBody;    
        }
        
        public function get Body():b2Body
        {
            return m_body;
        }
        
        public function Clone():IEditable
        {
            return new BoxEditable(m_editor, X, Y, Width, Height, Angle, m_dynamicBody);
        }
        
        public function ToXml():XML
        {
            var boxEditable:XML = <boxeditable/>;
            boxEditable.@x = X;
            boxEditable.@y = Y;
            boxEditable.@angle = Angle;
            boxEditable.@width = Width;
            boxEditable.@height = Height;
            boxEditable.@dynamicbody = m_dynamicBody;
            return boxEditable;
        }
        
        public static function FromXML(editor:Editor, boxEditable:XML):IEditable
        {
            var x:Number = parseFloat(boxEditable.@x);
            var y:Number = parseFloat(boxEditable.@y);
            var angle:Number = parseFloat(boxEditable.@angle);
            var width:Number = parseFloat(boxEditable.@width);
            var height:Number = parseFloat(boxEditable.@height);
            var dynamicBody:Boolean = boxEditable.@dynamicbody;
            
            var newBox:BoxEditable = new BoxEditable(editor, x, y, width, height, angle, dynamicBody);
            return newBox;         
        }
        
        public function SyncTransformFromPhysics():void
        {
            //  The physics model may change our location and orientation
            var pos:b2Vec2 = m_body.GetPosition();
            X = pos.x;
            Y = pos.y;
            Angle = m_body.GetAngle();
            
            UpdateSelectionSprite();
        }

        public function MoveTo(x:Number, y:Number):Boolean
        {
            X = x;
            Y = y;
            return true;
        }

        public function Translate(x:Number, y:Number):Boolean
        {
            X += x;
            Y += y;
            return true;
        }

        public function Scale(width:Number, height:Number):Boolean
        {
            Width = width*2;
            Height = height*2;
            return true;
        }
        
        public function ToggleDynamic():Boolean
        {
            m_dynamicBody = !m_dynamicBody;
            return true;
        }
        
        public function Rotation(angle:Number):Boolean
        {
            Angle = angle;
            return true;
        }

        private function CreateBody():void
        {
            if (m_body == null) {
                //  Create a new shape
                var boxShapeDef:b2PolygonDef = new b2PolygonDef();
                var boxBodyDef:b2BodyDef = new b2BodyDef();

                if (m_dynamicBody) {
                    boxShapeDef.density = 4.0;
                    boxShapeDef.friction = 0.3;
                }
                
                boxShapeDef.SetAsBox(Width/2, Height/2);
                boxBodyDef.position.Set(X, Y);
                boxBodyDef.angle = Angle;
                boxBodyDef.userData = this;

                m_body = m_editor.World.CreateBody(boxBodyDef);
                m_body.CreateShape(boxShapeDef);
                
                if (m_dynamicBody) {
                    m_body.SetMassFromShapes();                    
                }
                
                UpdateSelectionSprite();                                
                m_editor.AddEditable(this);                               
            }            
        }
        
        private function UpdateSelectionSprite():void {
            if (m_body) {
                m_selection.graphics.clear();
                m_selection.graphics.beginFill(0xccff00, 0.5);
                m_selection.graphics.drawRect(m_editor.w2s(-Width/2), m_editor.w2s(-Height/2), 
                                              m_editor.w2s(Width), m_editor.w2s(Height));
                m_selection.graphics.endFill();
                
                m_selection.x = m_editor.w2s(X);
                m_selection.y = m_editor.w2s(Y);
                m_selection.rotation = 180 * (Angle / Math.PI);                            
            }
        }

        public function DestroyBody():void
        {
            if (m_body) {
                m_editor.World.DestroyBody(m_body);
                m_body = null;
            }
        }
        
        public function Realize():void
        {
            // Destroy the existing physics entity if present and recreate it
            DestroyBody();
            CreateBody();
        }
        
        public function SetSelected(selected:Boolean):void {
            m_selected = selected;
            if (selected) {
                m_editor.AddChild(m_selection);
            }
            else {
                m_editor.RemoveChild(m_selection);
            } 
        }
    }
}
