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

    //  Select mode
    public class MSelect
    {
        // private members
        private var m_editor:Editor;
        private var m_sprite:Sprite;

        public var ModeString:String = "Select";

        private var m_mode:int;
        
        private static var SELECT_MODE:int    = 0;
        private static var TRANSLATE_MODE:int = 1;
        private static var SCALE_MODE:int     = 2;
        private static var ROTATE_MODE:int    = 3;
        
        public function MSelect(editor:Editor)
        {
            m_editor = editor;
            m_mode = SELECT_MODE;
        }

        public function OnBegin():void
        {
            SetMode(SELECT_MODE);
        }

        public function OnEnd():void
        {
        }

        private function Deselect():void
        {
            //  Deselect current selection
            m_editor.Selected.SetSelected(false);
            m_editor.Selected = null;
            SetMode(SELECT_MODE);            
        }
        
        private function SetMode(mode:int):void 
        {
            m_mode = mode;
            if (mode == SELECT_MODE) {
                if (m_editor.Selected) {
                    ModeString = "Select (active)";
                }
                else {
                    ModeString = "Select";
                }
            }
            else if (mode == TRANSLATE_MODE) {
                ModeString = "Select (translate)";
            }
            else if (mode == SCALE_MODE) {
                ModeString = "Select (scale)";
            }
            else if (mode == ROTATE_MODE) {
                ModeString = "Rotate";
            }
        }
        
        public function Update():void
        {
            var d:Number = 1 / (m_editor.b2Scale);

            //  Recreate the selection if moved
            var recreateSelection:Boolean = false;
            
            if (m_mode == SELECT_MODE) {
                
                // PageUp/PageDown - cycle through editables
                var prevPressed:Boolean = Input.isKeyPressed(33);
                var nextPressed:Boolean = Input.isKeyPressed(34);
                
                if (Input.mouseReleased) {
                    if (m_editor.Selected) {
                        Deselect();
                    }
    
                    var body:b2Body = m_editor.GetBodyAtMouse(true);
                    if (body != null) {
                        var editable:IEditable = body.GetUserData() as IEditable;
                        m_editor.Selected = editable;
                        editable.SetSelected(true);
                        SetMode(SELECT_MODE);
                    }
                }
                else if (prevPressed || nextPressed) {
                    var index:int = m_editor.Editables.indexOf(m_editor.Selected);
                    var length:int = m_editor.Editables.length;
                    
                    var nextIndex:int;
                    if (m_editor.Selected) {
                        nextIndex = (nextPressed ? (index + 1) : (index + length - 1)) % length;
                        Deselect();
                    }
                    else {
                        nextIndex = 0;
                    }
                    
                    m_editor.Selected = m_editor.Editables[nextIndex];
                    m_editor.Selected.SetSelected(true);
                    SetMode(SELECT_MODE);
                }
                else if (Input.isKeyDown(37)) {
                    recreateSelection = m_editor.Selected.Translate(-d,0);
                }
                else if (Input.isKeyDown(38)) {
                    recreateSelection = m_editor.Selected.Translate(0,-d);
                }
                else if (Input.isKeyDown(39)) {
                    recreateSelection = m_editor.Selected.Translate(d, 0);
                }
                else if (Input.isKeyDown(40)) {
                    recreateSelection = m_editor.Selected.Translate(0, d);
                }
                else if (Input.isKeyPressed(68)) {
                    // D - toggle dynamic on a body
                    if (m_editor.Selected && m_editor.Selected.ToggleDynamic()) {
                        m_editor.Selected.Realize();
                    }
                }
                else if (Input.isKeyPressed(80)) {
                    // P - clone selection
                    if (m_editor.Selected) {
                        var clone:IEditable = m_editor.Selected.Clone();
                        clone.MoveTo(m_editor.mX, m_editor.mY);
                        clone.Realize();
                    }
                }
                else if (Input.isKeyPressed(82)) {
                    // R - rotate current selection
                    if (m_editor.Selected) {
                        SetMode(ROTATE_MODE);
                    }
                }
                else if (Input.isKeyPressed(83)) {
                    // S - scale current selection
                    if (m_editor.Selected) {
                        SetMode(SCALE_MODE);
                    }
                }
                else if (Input.isKeyPressed(84)) {
                    // T - begin translating current selection
                    // XXX this is pretty inefficient, if it gets too slow then try
                    // destroying the body and just drawing the selection until it is
                    // placed, then finally recreating the body
                    if (m_editor.Selected) {
                        SetMode(TRANSLATE_MODE);                                                                                        
                    }
                }
                else if (Input.isKeyPressed(88)) {
                    // X - delete current selection
                    if (m_editor.Selected) {
                        m_editor.Selected.DestroyBody();
                        Deselect();
                    }
                }                
            }
            else if (m_mode == SCALE_MODE) {
                if (Input.mouseReleased || Input.isKeyPressed(13)) {
                    SetMode(SELECT_MODE);
                }
                else {
                    // XXX hack to get around the type system here...
                    var selected = m_editor.Selected;

                    // extents
                    var width:Number = Math.abs(m_editor.mX - selected.X);
                    var height:Number = Math.abs(m_editor.mY - selected.Y);
                    
                    recreateSelection = m_editor.Selected.Scale(width, height);
                }
            }            
            else if (m_mode == TRANSLATE_MODE) {
                if (Input.mouseReleased || Input.isKeyPressed(13)) {
                    SetMode(SELECT_MODE);
                }
                else {
                    recreateSelection = m_editor.Selected.MoveTo(m_editor.mX, m_editor.mY);
                }                
            }
            else if (m_mode == ROTATE_MODE) {
                // XXX hack to get around the type system here...
                var selected = m_editor.Selected;
                var angle:Number = selected.Angle;

                var modified:Boolean = false;        
                if (Input.isKeyPressed(219)) {
                    // '[' - decrease rotation angle
                    angle -= 0.05;
                    modified = true;    
                }
                else if (Input.isKeyPressed(221)) {
                    // '[' - increase rotation angle
                    angle += 0.05;
                    modified = true;
                }
                
                if (modified) {
                    recreateSelection = m_editor.Selected.Rotation(angle);
                }
                
                if (Input.mousePressed) {
                    SetMode(SELECT_MODE);
                }                
            }
            
            if (recreateSelection) {
                m_editor.Selected.Realize();
            }
        }

        public function CheckMode():Boolean
        {
            if (Input.isKeyPressed(83)) {
                return true;
            }
            
            return false;
        }
    }

}
