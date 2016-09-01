import edge.TimeSpan;

import AComponent;
import AProperty;
import utest.Assert;
import edge.Engine;
import edge.Entity;
import edge.Phase;
import edge.StatusChange;
import edge.Processor;
import edge.ProcessorSystem;
using thx.Iterators;
import thx.ReadonlyArray;

class TestProcessor {
  var events: Array<StatusChange<AComponent, AProperty>>;
  public function new() {
    var e = new Entity([CA], function(_) {});
    events = [
      PropertyAdded(EA),
      PropertyRemoved(EA),
      EntityCreated(e),
      EntityUpdated(e),
      EntityRemoved(e)
    ];
  }

  public function testBasics() {
    var p = new Phase(null),
        comps = [],
        envs = [];
    p.processComponentsProperties(
      function(e: ReadonlyArray<AComponent>) {
        comps.push(e.copy());
        return Some("comp");
      },
      function(e: ReadonlyArray<AProperty>) {
        envs.push(e.copy());
        return Some("env");
      }
    );
    for(e in events)
      p.propagate(e);
    Assert.same([[CA], [CA]], comps);
    Assert.same([[EA], []], envs);
  }
}
