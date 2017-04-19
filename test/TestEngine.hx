import AComponent;
import AProperty;
import utest.Assert;
import edge.Engine;
import thx.Maybe;

class TestEngine {
  public function new() {}

  public function testPropagationAfterSystem() {
    var engine = new Engine(),
        phase = engine.phases.create(),
        countComps = 0,
        countEnv = 0;
    phase.processComponentsProperties(
      function(e) {
        countComps++;
        Assert.same(CA, e[0]);
        return Maybe.none();
      },
      function(e) {
        countEnv++;
        Assert.same(EA, e[0]);
        return Maybe.none();
      }
    );
    Assert.equals(0, countComps);
    Assert.equals(0, countEnv);
    engine.entities.create([CA]);
    engine.properties.add(EA);
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
  }

  public function testPropagationBeforeSystem() {
    var engine = new Engine(),
        phase = engine.phases.create(),
        countComps = 0,
        countEnv = 0;
    engine.entities.create([CA]);
    engine.properties.add(EA);
    phase.processComponentsProperties(
      function(e) {
        countComps++;
        Assert.same(CA, e[0]);
        return Maybe.none();
      },
      function(e) {
        countEnv++;
        Assert.same(EA, e[0]);
        return Maybe.none();
      }
    );
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
    engine.entities.create([CA]);
    engine.properties.add(EA);
    Assert.equals(2, countComps);
    Assert.equals(2, countEnv);
  }

  public function testPropagationAfterPhase() {
    var engine = new Engine(),
        countComps = 0,
        countEnv = 0;
    engine.entities.create([CA]);
    engine.properties.add(EA);
  var phase = engine.phases.create();
  phase.processComponentsProperties(
      function(e) {
        countComps++;
        Assert.same(CA, e[0]);
        return Maybe.none();
      },
      function(e) {
        countEnv++;
        Assert.same(EA, e[0]);
        return Maybe.none();
      }
    );
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
    engine.entities.create([CA]);
    engine.properties.add(EA);
    Assert.equals(2, countComps);
    Assert.equals(2, countEnv);
  }

  public function testAddRemoveComponent() {
    var engine = new Engine(),
        phase = engine.phases.create(),
        comps = null;
    phase.processComponents(
      function(e) {
        comps = e;
        return Maybe.none();
      }
    );
    var e = engine.entities.create([CA]);
    Assert.same([CA], comps);
    e.addComponent(CB);
    Assert.same([CA, CB], comps);
    e.removeComponent(function(c) return c == CA);
    Assert.same([CB], comps);
  }

  public function testRemoveProperty() {
    var engine = new Engine(),
        phase = engine.phases.create(),
        envs = null;
    phase.processProperties(
      function(e) {
        envs = e;
        return Maybe.none();
      }
    );
    engine.properties.add(EA);
    Assert.same([EA], envs);
    engine.properties.add(EB);
    Assert.same([EA, EB], envs);
    engine.properties.remove(function(e) return e == EA);
    Assert.same([EB], envs);
  }
}
