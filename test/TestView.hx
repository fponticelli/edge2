import edge.TimeSpan;

import AComponent;
import AEnvironment;
import utest.Assert;
import edge.Engine;
import edge.Entity;
import edge.Phase;
import edge.StatusChange;
import edge.View;
import edge.ViewSystem;
using thx.Iterators;

class TestView {
  var events: Array<StatusChange<AComponent, AEnvironment>>;
  public function new() {
    var e = new Entity([CA], function(_) {});
    events = [
      EnvironmentAdded(EA),
      EnvironmentRemoved(EA),
      EntityCreated(e),
      EntityUpdated(e),
      EntityRemoved(e)
    ];
  }

  public function testBasics() {
    var p = new Phase(null),
        comps = [],
        envs = [];
    p.addView(View.componentsEnvironments(
      function(e: Iterator<AComponent>) {
        comps.push(e.toArray());
        return Some("comp");
      },
      function(e: Iterator<AEnvironment>) {
        envs.push(e.toArray());
        return Some("env");
      }
    ));
    for(e in events)
      p.propagate(e);
    Assert.same([[CA], [CA]], comps);
    Assert.same([[EA], []], envs);
  }
}
