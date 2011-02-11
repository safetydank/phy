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
	
	import flash.text.*;

    //  Select mode
    public class MGrab
    {
        private var m_mode:int;
        private static var GRAB_MODE:int = 0;
        private static var GRAB_CENTER_MODE:int = 1;
        private static var PUSH_MODE:int = 2;
        
        // private members
        private var m_editor:Editor;

        public var ModeString:String;

        //  Mouse joint for dragging objects
		public var m_mouseJoint:b2MouseJoint = null;

        private var m_x1:Number = 0;
        private var m_y1:Number = 0;
        private var m_x2:Number = 0;
        private var m_y2:Number = 0;

        private var m_newBox:BoxEditable;
    
        public function MGrab(editor:Editor)
        {
            m_editor = editor;
            SetMode(GRAB_MODE);
        }

        public function OnBegin():void
        {
        }

        public function OnEnd():void
        {
            DestroyMouseJoint();
        }
        
        private function SetMode(mode:int):void
        {
            m_mode = mode;
            if (mode == GRAB_MODE) {
                ModeString = "Grab";
            }
            else if (mode == GRAB_CENTER_MODE) {
                ModeString = "Grab (center)";
            }
            else if (mode == PUSH_MODE) {
                ModeString = "Push selected";
            }
        }

        private function SetNextMode():void
        {
            if (m_mode == GRAB_MODE) {
                SetMode(GRAB_CENTER_MODE);
            }
            else if (m_mode == GRAB_CENTER_MODE) {
                if (m_editor.Selected) {
                    SetMode(PUSH_MODE);
                }
                else {
                    SetMode(GRAB_MODE);
                }
            }
            else if (m_mode == PUSH_MODE) {
                SetMode(GRAB_MODE);
            }            
        }
        
        private function Push():void {
            var selected:IEditable = m_editor.Selected;
            if (Input.isKeyDown(37)) {
                //  Move left
                selected.Body.WakeUp();
                selected.Body.m_linearVelocity.x = -3;
            }
            else if (Input.isKeyDown(38)) {
                //  Move up
                selected.Body.m_linearVelocity.y = -3; 		
            }
            else if (Input.isKeyDown(39)) {
                //  Move right
                selected.Body.WakeUp();
                selected.Body.m_linearVelocity.x = 3;
            }
            else if (Input.isKeyDown(40)) {                
                //  Move down
                selected.Body.WakeUp();
                selected.Body.m_linearVelocity.y = 3;
            }            
        }
        
        public function Update():void
        {
            // G - cycle through grab modes
            if (Input.isKeyPressed(71)) {
                SetNextMode();
            }                       
            
            if (m_mode == PUSH_MODE) {
                Push();
            }
            else {
                if (Input.mouseDown && !m_mouseJoint) {
                    var body:b2Body = m_editor.GetBodyAtMouse();
                    
                    if (body)
                    {
                        var md:b2MouseJointDef = new b2MouseJointDef();
                        md.body1 = m_editor.World.GetGroundBody();
                        md.body2 = body;
                        
                        var x:Number, y:Number;
                        if (m_mode == GRAB_MODE) {
                            x = m_editor.mX;
                            y = m_editor.mY;
                        }
                        else {
                            var center:b2Vec2 = body.GetWorldCenter();
                            x = center.x;
                            y = center.y;
                        }
                        md.target.Set(x, y);
                        
                        md.maxForce = 100.0 * body.GetMass();
                        md.timeStep = m_editor.Timestep;
                        m_mouseJoint = m_editor.World.CreateJoint(md) as b2MouseJoint;
                        body.WakeUp();
                    }
                }
             
                // mouse release
                if (!Input.mouseDown) {
                    DestroyMouseJoint();
                }
                
                // mouse move
                if (m_mouseJoint) {
                	var p2:b2Vec2 = new b2Vec2(m_editor.mX, m_editor.mY);
                	m_mouseJoint.SetTarget(p2);
                }                                        
            }
        }
        
        private function DestroyMouseJoint():void {
         	if (m_mouseJoint) {
         		m_editor.World.DestroyJoint(m_mouseJoint);
         		m_mouseJoint = null;
         	}            
        }

        public function CheckMode():Boolean
        {
            // G - enter Grab mode
            if (Input.isKeyPressed(71)) {
                return true;
            }
            
            return false;
        }
    }

}
