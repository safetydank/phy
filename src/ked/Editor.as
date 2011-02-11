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

	/**
     * a vi-like physics editor
     *
	 * @author Dan
	 */
	public class Editor
	{
        //  A selected editable (box)
        public var Selected:IEditable = null;

        private var m_modes:Array;
        
        //  Leave this loosely typed, later implement IMode interface
		private var m_activeMode;
				
        private var m_editModeText:TextField;

        public var World:b2World;
        public var Timestep:Number = 1.0 / 30.0;
        public var b2Scale:Number;
        
		private var m_iterations:int = 10;

        //  Sprite surface to draw on
        private var m_surface:Sprite;
        private var m_destructionListener:KedDestructionListener;

        // Mouse x, y coords in world space
        public var mX:Number; 
        public var mY:Number;

        //  Array of IEditable instances
        public var Editables:Array;

		// surface -- sprite to draw Physics world to
		// box2DScale -- a scaling factor representing pixel:world unit ratio
		public function Editor(surface:Sprite, box2Dscale:Number)
		{
            m_surface = surface;
			b2Scale = box2Dscale;
            Editables = new Array();

			var worldAABB:b2AABB = new b2AABB();
			
			//  Set world bounds
			worldAABB.lowerBound.Set(-1000.0, -1000.0);
			worldAABB.upperBound.Set(1000.0, 1000.0);
			
			var gravity:b2Vec2 = new b2Vec2(0.0, 9.8);
			var doSleep:Boolean = true;
			
			World = new b2World(worldAABB, gravity, doSleep);
            m_destructionListener = new KedDestructionListener(this);
            World.SetDestructionListener(m_destructionListener);

            m_modes = new Array();
            m_modes.push(new MSelect(this));
			m_modes.push(new MCreate(this));
			m_modes.push(new MGrab(this));
			m_modes.push(new MScene(this));
            m_activeMode = null;

            m_editModeText = new TextField();
            var textFormat:TextFormat = new TextFormat("Arial", 16, 0xffffff, false, false, false);
            m_editModeText.defaultTextFormat = textFormat;
            m_editModeText.x = 20;
            m_editModeText.y = 4.5;
            m_editModeText.width = 495;
            m_editModeText.height = 61;

            m_surface.addChild(m_editModeText);

            DebugDraw(true);
		}		

        public function AddChild(child:Sprite):void {
            m_surface.addChild(child);
        }

        public function RemoveChild(child:Sprite):void {
            m_surface.removeChild(child);
        }

        public function DebugDraw(debugOn:Boolean):void
        {
            if (debugOn) {
			    var dbgDraw:b2DebugDraw = new b2DebugDraw();
			    dbgDraw.m_sprite = m_surface;
                dbgDraw.m_drawScale = b2Scale;
                dbgDraw.m_fillAlpha = 0.3;
                dbgDraw.m_lineThickness = 1.0;
                dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit;
			    World.SetDebugDraw(dbgDraw);
            }
            else {
                World.SetDebugDraw(null);
            }
        }

        public function DestroyWorld():void {

        }

        public function s2w(coord:Number):Number {
            //  scales a screen space coord to world space
			return coord / b2Scale;
        }

        public function w2s(coord:Number):Number {
            //  scales a world coord to screen space
            return coord * b2Scale;
        }

        public function Update():void
        {
            //  Normalize mouse input to world coords
            mX = s2w(Input.mouseX);
            mY = s2w(Input.mouseY);

            // Escape pressed
            if (m_activeMode && Input.isKeyDown(27)) {
                m_activeMode.OnEnd();
                m_activeMode = null;
            }
                
            if (m_activeMode) {
                m_activeMode.Update();
                
                //  Update mode text
                m_editModeText.text = m_activeMode.ModeString;            
            }
            else {
                m_editModeText.text = "(pick a mode)";
                SelectEditMode();
            }

            World.Step(Timestep, m_iterations);
            for (var i:int=0; i < Editables.length; ++i) {
                Editables[i].SyncTransformFromPhysics();
            }
        }

        public function AddEditable(editable:IEditable):void
        {
            Editables.push(editable);
        }

        public function RemoveEditable(editable:IEditable):void
        {
            var index:int = Editables.indexOf(editable);
            if (index >= 0) {
                Editables.splice(index, 1);
            }
        }

		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:b2Vec2 = new b2Vec2();
		public function GetBodyAtMouse(includeStatic:Boolean=false):b2Body
        {
			// Make a small box.
			mousePVec.Set(mX, mY);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mX - 0.001, mY - 0.001);
			aabb.upperBound.Set(mX + 0.001, mY + 0.001);
			
			// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = World.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].GetBody().IsStatic() == false || includeStatic)
				{
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.GetBody().GetXForm(), mousePVec);
					if (inside)
					{
						body = tShape.GetBody();
						break;
					}
				}
			}
			return body;
		}

        public function SelectEditMode():void
        {
            for each(var mode in m_modes) {
                mode.CheckMode();
            }
            for (var i:int=0; i < m_modes.length; ++i) {
                if (m_modes[i].CheckMode()) {
                    m_activeMode = m_modes[i];
                    m_activeMode.OnBegin();
                    m_editModeText.text = m_activeMode.ModeString;
                    break;
                }
            }
        }
	}	
}
