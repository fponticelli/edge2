package edge.kha;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import edge.Phase;

class World<Component, Environment> {
  public var frame(default, null): Phase<Component, Environment>;
  public var physics(default, null): Phase<Component, Environment>;
  public var render(default, null): Phase<Component, Environment>;
  public var engine(default, null): Engine<Component, Environment>;
  public var delta(default, null): Float;
  public var running(default, null): Bool;
  public var collision(default, null): Phase<Component, Environment>;
  public var collisionDelay(default, null): Float;
	public var framebuffer(default, null): Framebuffer;

  var schedule : (Float -> Void) -> (Void -> Void);
  var cancel : Void -> Void;
  var remainder : Float;
	var last: Float;
	var t: Float;
  public function new(engine: Engine<Component, Environment>, ?delta : Float = 16, ?collisionDelay : Float = 50) {
    this.engine    = engine;
    this.frame     = engine.createPhase();
    this.physics   = engine.createPhase();
    this.render    = engine.createPhase();
    this.collision = engine.createPhase();
    this.remainder = 0;
    this.running = false;
    this.delta = delta;
    this.collisionDelay = collisionDelay;
		last = time();
		t = 0;
		System.notifyOnRender(_render);
		Scheduler.addTimeTask(_update, 0, delta / 1000);
    Scheduler.addTimeTask(_collision, 0, collisionDelay / 1000);
  }

	function _render(framebuffer: Framebuffer) {
		this.framebuffer = framebuffer;
		render.update();
	}

  function _collision() {
    collision.update();
  }

	function _update() {
		t = time() - last;
    frame.update();
    var dt = t + remainder;
    while(dt > delta) {
      dt -= delta;
      physics.update();
    }
    remainder = dt;
		last = time();
	}

	inline function time()
		return System.time * 1000;
}
