package src.ent;

import haxe.Timer;
import hxd.Window;
import h2d.Bitmap;

class Ball extends Entity {
	public var type:Const.ENTITIES;

	var onGoal:Goal->Void;
    var prevCollision:Entity;
    var canCollide:Bool;

	public function new(cx:Int, cy:Int, s2d:h2d.Object, onGoal:Goal->Void, type:Const.ENTITIES) {
		var r = Const.BALL_R;
		var spr = new h2d.Bitmap(h2d.Tile.fromColor(0xff0000, 2 * r, 2 * r), s2d);
		super(cx, cy, r, r, spr);
		this.type = type;
        this.prevCollision = null;
        this.canCollide = true;

		// The ball should not slow down over time.
		this.friction = 1;
		this.onGoal = onGoal;

        // Launch the ball in a random direction to start.
		this.dx = Const.BALL_MAX_SPEED * (Math.random()) - (Const.BALL_MAX_SPEED / 2);
        this.dy = Const.BALL_MAX_SPEED * (Math.random()) - (Const.BALL_MAX_SPEED / 2);
        
        //Debug:
        // this.dx = Const.BALL_MAX_SPEED / 2;
	}

	private function collides(e:Entity) {
		// Fast distance check
		if (Math.abs(cx - e.cx) <= 100) {
			// Real distance check
			var xdist = Math.abs(e.cx + e.xr - cx - xr);
			var ydist = Math.abs(e.cy + e.yr - cy - yr);

			if (xdist <= e.hitW + this.hitW && ydist <= e.hitH + this.hitH) {

                
                Timer.delay( ()-> canCollide=true,300);
                canCollide = false;

                // Update previous collision
                prevCollision = e;

				// Handle scoring
				if (Std.is(e, Goal)) {
					delete();
                    onGoal(cast(e, Goal));
                    return true;
                }

				// There was no goal: hit the ball back slightly faster.
				dx *= -1.2;
                dy *= 1.2;
                // trace("new dx: " + dx + " new dy: " + dy);
                
                return true;
			}
        }
        return false;
	}

	private function delete() {
		spr.tile.dispose();
		if (spr.parent != null)
			spr.parent.removeChild(this.spr);
	}

	public function preUpdateTask(entities:Any) {
		// Check for collisions before moving.
		if (!Std.is(entities, Array))
			return;
		for (entity in (entities : Array<Entity>)) {
            if (canCollide && !(entity==prevCollision))
			    if(collides(entity)) break;
		}
	}

	public function postUpdateTask(data:Any) {

		// After moving, keep the ball on screen.
		if (cx + Const.BALL_R > Window.getInstance().width || cx - Const.BALL_R < 0) {
			dx *= -1;
		}
		if (cy + Const.BALL_R > Window.getInstance().height || cy - Const.BALL_R < 0) {
			dy *= -1;
        }
        
		// Keep the ball's speed capped.
		if (Math.abs(dx) > Const.BALL_MAX_SPEED) {
            if ( dx < 0 ) dx = Const.BALL_MAX_SPEED * -1
            else dx = Const.BALL_MAX_SPEED;
		}

		if (Math.abs(dy) > Const.BALL_MAX_SPEED) {
            if ( dy < 0) dy = Const.BALL_MAX_SPEED * -1;
            else dy = Const.BALL_MAX_SPEED;
		}
	}
}
