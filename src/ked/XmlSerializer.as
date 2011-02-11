package ked
{
    public class XmlSerializer
    {
        //  Serialize the scene to/from XML
        
        private var m_editor:Editor;
        public function XmlSerializer(editor:Editor)
        {
            m_editor = editor;                       
        }
        
        public function CreateXml():XML
        {
            var sceneXML:XML = <scene/>;
            for each (var editable:IEditable in m_editor.Editables) {
                //  XXX Another loose typing hack
                var newEditableNode:XML = editable.ToXml();
                sceneXML.appendChild(newEditableNode);                
            }
            
            return sceneXML;
        }
        
        public static function SceneFromXML(editor:Editor, sceneXML:XML):Array
        {
            var editables:Array = new Array();
                        
            // XXX needs work
            // just creates the Editables array for now
            for each (var element:XML in sceneXML.elements()) {
                var editable:IEditable = null;
                if (element.name() == "boxeditable") {
                    editable = BoxEditable.FromXML(editor, element);
                }
                else if (element.name() == "circleeditable") {
                    editable = CircleEditable.FromXml(editor, element);
                }
                
                if (editable) {
                    //  XXX recreate may need to be optionally applied, controlled with an XML attribute
                    editable.Realize();
                    editables.push(editable);    
                }
            }
            
            return editables;   
        }         
    }
}