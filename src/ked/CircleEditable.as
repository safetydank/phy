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

    public class CircleEditable implements IEditable
    {
		private var m_editor:Editor;

        //  Box placement and dimensions
        public var X:Number;
        public var Y:Number;
        public var Radius:Number;
        public var Angle:Number;

        private var m_dynamicBody:Boolean;
        
        //  Physics data
        private var m_body:b2Body;
        
        private var m_selection:Sprite;        
        private var m_selected:Boolean = false;

        public function CircleEditable(world:Editor,
								       x:Number, y:Number, 
                                       radius:Number, angle:Number,
                                       isDynamicBody:Boolean)
        {
            m_editor = world;
            m_body = null;

            //  Location in world coords
            MoveTo(x, y);

            //  Circle radius
            Radius = radius;
            
            //  Orientation (rad)
            Angle = angle;
            
            //  Selection highlight
            m_selection = new Sprite();
            
            m_dynamicBody = isDynamicBody;
        }
        
        public function get Body():b2Body
        {
            return m_body;
        }
        
        public function Clone():IEditable
        {
            return new CircleEditable(m_editor, X, Y, Radius, Angle, m_dynamicBody);
        }
        
        public function ToXml():XML
        {
            var circleEditable:XML = <circleeditable/>;
            circleEditable.@x = X;
            circleEditable.@y = Y;
            circleEditable.@angle = Angle;
            circleEditable.@radius = Radius;
            circleEditable.@dynamicbody = m_dynamicBody;
            return circleEditable;            
        }
        
        public static function FromXml(editor:Editor, circleEditable:XML):IEditable
        {
            var x:Number = parseFloat(circleEditable.@x);
            var y:Number = parseFloat(circleEditable.@y);
            var angle:Number = parseFloat(circleEditable.@angle);
            var radius:Number = parseFloat(circleEditable.@radius);
            var dynamicBody:Boolean = circleEditable.@dynamicbody;
            
            var newCircle:CircleEditable = new CircleEditable(editor, x, y, radius, angle, dynamicBody);
            return newCircle;            
        }

        public function SyncTransformFromPhysics():void
        {
            //  The physics model may change our location and orientation
            if (m_body) {
                var pos:b2Vec2 = m_body.GetPosition();
                X = pos.x;
                Y = pos.y;
                Angle = m_body.GetAngle();
                
                m_selection.x = m_editor.w2s(X);                
                m_selection.y = m_editor.w2s(Y);                
            }
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
            Radius = Math.sqrt(width*width + height*height);
            return true;
        }
        
        public function Rotation(angle:Number):Boolean
        {
            Angle = angle;
            return true;
        }
        
        public function ToggleDynamic():Boolean
        {
            m_dynamicBody = !m_dynamicBody;
            return true;
        }

        private function CreateBody():void
        {
            if (m_body == null) {
                //  Create a new shape
                var circleDef:b2CircleDef = new b2CircleDef();
                var circleBodyDef:b2BodyDef = new b2BodyDef();
                
                circleBodyDef.position.Set(X, Y);
                circleBodyDef.userData = this;
                circleBodyDef.angle = Angle;

                circleDef.radius = Radius;
                
                if (m_dynamicBody) {
                    circleDef.density = 8.0;
                    circleDef.friction = 0.3;
                    circleDef.restitution = 0.2;
                }
                
                m_body = m_editor.World.CreateBody(circleBodyDef);
                m_body.CreateShape(circleDef);
                
                if (m_dynamicBody) {
                    m_body.SetMassFromShapes();
                }
                                
                UpdateSelectionSprite();                                
                m_editor.AddEditable(this);                               
            }            
        }
        
        private function UpdateSelectionSprite():void {
            if (m_body) {
                m_selection.x = m_editor.w2s(X);
                m_selection.y = m_editor.w2s(Y);
                
                m_selection.graphics.clear();
                m_selection.graphics.beginFill(0xccff00, 0.5);
                m_selection.graphics.drawCircle(0, 0, m_editor.w2s(Radius));
                m_selection.graphics.endFill();                           
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
