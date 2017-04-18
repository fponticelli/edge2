import utest.Assert;
import edge.Entity;
import edge.Phase;
import edge.StatusChange;
import edge.Processor;
import AComponent;
import AProperty;
import haxe.ds.Option;

class TestPhase {
  public function new() {}

  public function testBasics() {
    var p = new Phase(null);
    var v = new TPProcessor();
    var vs = p.addProcessor(v);
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

class TPProcessor<Payload, Component, Property> implements Processor<Payload, Component, Property> {
  public var collected: Array<StatusChange<Component, Property>> = [];
  public function new() {}
  public function onChange(change: StatusChange<Component, Property>): Void {
    collected.push(change);
  }
  public function payload() return None;
}
