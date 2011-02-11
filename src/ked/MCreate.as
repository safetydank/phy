package ked 
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.*;
	
	import General.Input;
	
	import flash.display.Sprite;
	import flash.text.*;

    //  Create mode
    public class MCreate
    {
        private static var CREATE_BOX_MODE:int = 0;
        private static var CREATE_CIRCLE_MODE:int = 1;
        private static var CREATE_MARKER_MODE:int = 2;
        
        private static var STATIC_BODY:int = 0;
        private static var DYNAMIC_BODY:int = 1;
        
        private var m_mode:int;
        private var m_bodyType:int;
        
        // private members
        private var m_editor:Editor;

        public var ModeString:String = "Create";
        private var m_dragging:Boolean;

        private var m_x1:Number = 0;
        private var m_y1:Number = 0;
        private var m_x2:Number = 0;
        private var m_y2:Number = 0;

        //  These selection boxes should be drawn by the editables themselves
        private var m_box:Sprite;
        private var m_circle:Sprite;
        private var m_selectionSprite:Sprite;        
        
        private var m_newBox:BoxEditable;
    
        public function MCreate(editor:Editor)
        {
            m_editor = editor;
            m_box = new Sprite();
            m_circle = new Sprite();
            m_mode = CREATE_BOX_MODE;
            m_bodyType = STATIC_BODY;
            UpdateModestring();
        }

        public function OnBegin():void
        {
            m_dragging = false;
            m_selectionSprite = null;
        }

        public function OnEnd():void
        {
            //  Interrupted creating a new editable, remove the creation highlighter
            if (m_selectionSprite) {
                m_editor.RemoveChild(m_selectionSprite);
            }            
        }

        private function UpdateBox(x:Number, y:Number, w:Number, h:Number):void
        {
            m_box.x = m_editor.w2s(x);
            m_box.y = m_editor.w2s(y);
            m_box.graphics.clear();
            m_box.graphics.beginFill(0xccff00, 0.5);
            m_box.graphics.drawRect(0, 0, m_editor.w2s(w), m_editor.w2s(h));
            m_box.graphics.endFill();            
        }

        private function UpdateCircle(x:Number, y:Number, r:Number):void
        {
            m_circle.x = m_editor.w2s(x);
            m_circle.y = m_editor.w2s(y);
            m_circle.graphics.clear();
            m_circle.graphics.beginFill(0xccff00, 0.5);
            m_circle.graphics.drawCircle(0, 0, m_editor.w2s(r));
            m_circle.graphics.endFill();            
        }

        private function UpdateModestring():void {
            var bodyType:String;

            if (m_bodyType == STATIC_BODY) {
                bodyType = "static";
            }
            else if (m_bodyType == DYNAMIC_BODY) {
                bodyType = "dynamic"
            }
            
            if (m_mode == CREATE_BOX_MODE) {
                ModeString = "Create box ("+bodyType+")";
            }
            else if (m_mode == CREATE_CIRCLE_MODE) { 
                ModeString = "Create circle ("+bodyType+")";
            }
        }
        
        public function Update():void
        {            
            if (m_dragging) {
                //  draw rubberbanding selection
                m_x2 = m_editor.mX;
                m_y2 = m_editor.mY;
            }

            // C key to change creation primitive (box/circle)
            var updateModestring:Boolean = false;
            if (Input.isKeyPressed(65) || Input.isKeyPressed(73)) {
                if (m_mode == CREATE_BOX_MODE) {
                    m_mode = CREATE_CIRCLE_MODE;
                }
                else if (m_mode == CREATE_CIRCLE_MODE) {
                    m_mode = CREATE_BOX_MODE;
                }    
                updateModestring = true;
            }
            
            // S key to toggle between static and dynamic body creation
            if (Input.isKeyPressed(83)) {
                if (m_bodyType == STATIC_BODY) {
                    m_bodyType = DYNAMIC_BODY;     
                }
                else if (m_bodyType == DYNAMIC_BODY) {
                    m_bodyType = STATIC_BODY;
                }
                updateModestring = true;
            }
            
            if (updateModestring) {
                UpdateModestring();
            }
                 
            var createBody:Boolean = false;
            var createSprite:Sprite;
                           
            if (m_mode == CREATE_BOX_MODE) {
                createSprite = m_box;
            }
            else if (m_mode == CREATE_CIRCLE_MODE) {
                createSprite = m_circle;
            }
            
            if (Input.mouseReleased) {
                if (m_dragging) {
                    //  end box
                    m_dragging = false;
                    m_editor.RemoveChild(createSprite);
                    m_selectionSprite = null;
                    
                    createBody = true;
                }
                else {
                    //  begin box
                    m_x1 = m_x2 = m_editor.mX;
                    m_y1 = m_y2 = m_editor.mY;
                    m_dragging = true;
                    m_editor.AddChild(createSprite);                    
                    m_selectionSprite = createSprite;            
                }
            }
            
            var x:Number = Math.min(m_x1, m_x2);
            var y:Number = Math.min(m_y1, m_y2);
            //  w and h represents extents (ie width/2, height/2)
            var w:Number = Math.max(m_x1, m_x2) - x;
            var h:Number = Math.max(m_y1, m_y2) - y;
            var radius:Number = Math.sqrt(w*w + h*h);            
            
            if (m_dragging) {
                if (m_mode == CREATE_BOX_MODE) {
                    UpdateBox(x, y, w, h);
                }
                else if (m_mode == CREATE_CIRCLE_MODE) {
                    UpdateCircle(x, y, radius);
                }
            }

            if (createBody) {
                var editable:IEditable;
                var isDynamicBody:Boolean = m_bodyType == DYNAMIC_BODY;
                if (m_mode == CREATE_BOX_MODE) {
                    // editable = new BoxEditable(m_editor, x, y, w*2, h*2, 0, isDynamicBody);                    
                    editable = new BoxEditable(m_editor, x+w/2, y+h/2, w, h, 0, isDynamicBody);                    
                }
                else if (m_mode == CREATE_CIRCLE_MODE) {
                    editable = new CircleEditable(m_editor, x, y, radius, 0, isDynamicBody); 
                }
                editable.Realize();
            }
        }

        public function CheckMode():Boolean
        {
            // A/I - enter create mode
            if (Input.isKeyPressed(65) || Input.isKeyPressed(73)) {
                return true;
            }
            
            return false;
        }
    }
}
