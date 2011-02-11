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

    //  Create mode
    public class MScene
    {
        // private members
        private var m_editor:Editor;

        public var ModeString:String = "Scene mode";

        public function MScene(editor:Editor)
        {
            m_editor = editor;
        }

        public function OnBegin():void
        {
        }

        public function OnEnd():void
        {
        }

        public function Update():void
        {
            if (Input.isKeyPressed(87)) {
                // W - export to XML
                var xs:XmlSerializer = new XmlSerializer(m_editor);
                var scene:XML = xs.CreateXml();
                trace(scene);
            }
            else if (Input.isKeyPressed(69)) {
                // XXX reset the scene first
                
                // E - read from XML
                var src:String = (<![CDATA[
<scene>
  <boxeditable x="0.7" y="1.25" angle="0" width="0.5666666666666667" height="14.183333333333334"/>
  <boxeditable x="0.13333333333333286" y="14.3" angle="0" width="20.46666666666667" height="1.299999999999999"/>
  <boxeditable x="19.9" y="0.43333333333333357" angle="0" width="0.9000000000000021" height="14.633333333333333"/>
  <circleeditable x="3.3666666666666667" y="13.609637784147454" angle="0" radius="0.6954215348341689"/>
  <circleeditable x="9.2" y="13.064173538980839" angle="0" radius="1.2373807462180395"/>
  <circleeditable x="16.3" y="11.616794019650044" angle="0" radius="2.6832815729997472"/>
</scene>                
                ]]>).toString();
                var srcXML:XML = new XML(src);
                var editables:Array = XmlSerializer.SceneFromXML(m_editor, srcXML);
                m_editor.Editables = editables;                
            }
        }

        public function CheckMode():Boolean
        {
            // ';' - enter create mode
            if (Input.isKeyPressed(186)) {
                return true;
            }
            
            return false;
        }
        
        
    }
}
