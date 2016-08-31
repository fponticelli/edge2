import edge.TimeSpan;

import utest.Assert;
import edge.Engine;
import edge.Entity;
import edge.Phase;
import edge.StatusChange;
import edge.View;
import AComponent;
import AProperty;

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
      PropertyAdded(EA),
      PropertyRemoved(EA),
      EntityCreated(e),
      EntityUpdated(e),
      EntityRemoved(e)
    ];
    for(e in events)
      p.propagate(e);
    Assert.same(events, v.collected);
  }
}

class TPView<Payload, Component, Property> extends View<Payload, Component, Property> {
  public var collected: Array<StatusChange<Component, Property>> = [];
  public function new() {}
  override public function onChange(change: StatusChange<Component, Property>): Void {
    collected.push(change);
  }
}
