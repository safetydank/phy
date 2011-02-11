package 
{
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Dynamics.Joints.*;
	
	import General.FRateLimiter;
	import General.Input;
	
	import flash.display.*;
	import flash.events.Event;
	
	import ked.*;
	
	/**
	 * ...
	 * @author Dan
	 */
	
	[SWF(width=640,height=480,backgroundColor='#000000')]
	public class Phy extends Sprite 
	{
		// Canvas sprite
		private var m_sprite:Sprite;
		
		// Physics world/editor
        // public var m_physicsWorld:PhysicsWorld;
		private var m_physicsEditor:Editor;
		
        // Input class
        public var m_input:Input;
        private var m_activeState = null;
		
		public function Phy():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);

			// entry point

            addEventListener(Event.ENTER_FRAME, update, false, 0, true);
            m_sprite = new Sprite();
            //  Set background color            
            addChild(m_sprite);

            m_input = new Input(m_sprite);

            m_physicsEditor = new Editor(m_sprite, 30.0);
            m_activeState = m_physicsEditor;
		}


		public function update(e:Event):void
        {
            m_sprite.graphics.clear();
            m_activeState.Update();

            //  Update input for the next tick
            Input.Update();
            FRateLimiter.limitFrame(30);
        }
	}	
}
