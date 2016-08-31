import edge.TimeSpan;

import utest.Assert;
import edge.Engine;
import edge.Entity;
import edge.Phase;
import edge.StatusChange;
import edge.View;
import AComponent;
import AEnvironment;

class TestPhase {
  public function new() {}

  public function testBasics() {
    var p = new Phase(null);
    var v = new TPView();
    var vs = p.addView(v);
    Assert.notNull(vs);
    Assert.same([], v.collected);
    var e = new Entity([CA], function(_) {});
    var events = [
      EnvironmentAdded(EA),
      EnvironmentRemoved(EA),
      EntityCreated(e),
      EntityUpdated(e),
      EntityRemoved(e)
    ];
    for(e in events)
      p.propagate(e);
    Assert.same(events, v.collected);
  }
}

class TPView<Payload, Component, Environment> extends View<Payload, Component, Environment> {
  public var collected: Array<StatusChange<Component, Environment>> = [];
  public function new() {}
  override public function onChange(change: StatusChange<Component, Environment>): Void {
    collected.push(change);
  }
}
