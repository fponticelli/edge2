package edge.kha;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import edge.Phase;
import edge.TimeSpan;

class World<Component, Environment> {
  public var frame(default, null): DeltaPhase<Component, Environment>;
  public var physics(default, null): DeltaPhase<Component, Environment>;
  public var render(default, null): DeltaPhase<Component, Environment>;
  public var engine(default, null): Engine<Component, Environment>;
  public var collision(default, null): DeltaPhase<Component, Environment>;
  public var collisionDelay(default, null): Float;
  public var delta(default, null): Float;
  var _framebuffer: Framebuffer;

  var schedule : (Float -> Void) -> (Void -> Void);
  var cancel : Void -> Void;
  var remainder : Float;
  var last: Float;
  var t: Float;
  public function new(engine: Engine<Component, Environment>, ?delta : Float = 16, ?collisionDelay : Float = 50) {
    this.engine    = engine;
    this.frame     = new DeltaPhase(engine.createPhase());
    this.physics   = new DeltaPhase(engine.createPhase());
    this.render    = new DeltaPhase(engine.createPhase());
    this.collision = new DeltaPhase(engine.createPhase());
    this.remainder = 0;
    this.delta     = delta;
    this.collisionDelay = collisionDelay;
    last = time();
    t = 0;
    System.notifyOnRender(_render);
    Scheduler.addTimeTask(_update, 0, delta / 1000);
    Scheduler.addTimeTask(_collision, 0, collisionDelay / 1000);
  }

  public function framebuffer()
    return _framebuffer;

  function _render(framebuffer: Framebuffer) {
    this._framebuffer = framebuffer;
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

class DeltaPhase<Component, Environment> {
  public var phase(default, null): Phase<Component, Environment>;

  var span: Float;
  var latest: Float;
  public function new(phase: Phase<Component, Environment>) {
    this.phase = phase;
    this.latest = System.time;
  }

  public function getDelta(): TimeSpan
    return TimeSpan.fromSeconds(span);

  public function update() {
    var now = System.time;
    span = now - latest;
    latest = now;
    phase.update();
  }
}