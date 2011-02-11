package ked
{
    import Box2D.Dynamics.b2Body;
    
    public interface IEditable
    {
//        function get X():Number;
//        function get Y():Number;

        //  Set editable x,y location.  This does not update the physics body's 
        //  location, the editable must be realized/recreated to see changes.
        function MoveTo(x:Number, y:Number):Boolean;

        //  Similarly translate the editable's position by (x,y) but doesn't update
        //  the physics body.
        function Translate(x:Number, y:Number):Boolean;
        
        //  Set the rotation of the editable (radians)
        function Rotation(angle:Number):Boolean;

        //  Change the size of the editable  
        function Scale(width:Number, height:Number):Boolean;
        
        function ToggleDynamic():Boolean;
                
        //  Destroy the physics body
        function DestroyBody():void;
        
        function get Body():b2Body;
        
        //  (Re)create the physics body with the current transformation settings
        function Realize():void;
        
        //  Set selected state on/off.  When selected the editable should be highlighted.
        function SetSelected(selected:Boolean):void;

        //  Synchronize transformation from physics model
        function SyncTransformFromPhysics():void;
        
        //  This will produce a clone of this editable. The clone must be realized in separate step.
        function Clone():IEditable;
        
        //  Produce an XML node representing the current state (used to serialize)
        function ToXml():XML;
    }
}