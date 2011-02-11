package ked
{
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;

    //  Nullify references to destroyed entities
    public class KedDestructionListener extends b2DestructionListener
    {
        private var m_editor:Editor;
        
        public function KedDestructionListener(editor:Editor)
        {
            m_editor = editor;
        }
        
        override public function SayGoodbyeJoint(joint:b2Joint) : void {
            joint = null;
        }

        override public function SayGoodbyeShape(shape:b2Shape) : void {
            //  Remove any associated editable from the editor
            var editable:IEditable = shape.GetBody().GetUserData() as IEditable;
            if (editable) {
                m_editor.RemoveEditable(editable);        
            }
            shape = null;
        }
    }
}

