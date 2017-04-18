import AComponent;
import AProperty;
import utest.Assert;
import edge.Engine;

class TestEngine {
  public function new() {}

  public function testPropagationAfterSystem() {
    var engine = Engine.withEnumProperty(),
        phase = engine.createPhase(),
        countComps = 0,
        countEnv = 0;
    phase.processComponentsProperties(
      function(e) {
        countComps++;
        Assert.same(CA, e[0]);
        return None;
      },
      function(e) {
        countEnv++;
        Assert.same(EA, e[0]);
        return None;
      }
    );
    Assert.equals(0, countComps);
    Assert.equals(0, countEnv);
    engine.createEntity([CA]);
    engine.addProperty(EA);
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
  }

  public function testPropagationBeforeSystem() {
    var engine = Engine.withEnumProperty(),
        phase = engine.createPhase(),
        countComps = 0,
        countEnv = 0;
    engine.createEntity([CA]);
    engine.addProperty(EA);
    phase.processComponentsProperties(
      function(e) {
        countComps++;
        Assert.same(CA, e[0]);
        return None;
      },
      function(e) {
        countEnv++;
        Assert.same(EA, e[0]);
        return None;
      }
    );
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
    engine.createEntity([CA]);
    engine.addProperty(EA);
    Assert.equals(2, countComps);
    Assert.equals(2, countEnv);
  }

  public function testPropagationAfterPhase() {
    var engine = Engine.withEnumProperty(),
        countComps = 0,
        countEnv = 0;
    engine.createEntity([CA]);
    engine.addProperty(EA);
  var phase = engine.createPhase();
  phase.processComponentsProperties(
      function(e) {
        countComps++;
        Assert.same(CA, e[0]);
        return None;
      },
      function(e) {
        countEnv++;
        Assert.same(EA, e[0]);
        return None;
      }
    );
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
    engine.createEntity([CA]);
    engine.addProperty(EA);
    Assert.equals(2, countComps);
    Assert.equals(2, countEnv);
  }

  public function testAddRemoveComponent() {
    var engine = Engine.withEnumProperty(),
        phase = engine.createPhase(),
        comps = null;
    phase.processComponents(
      function(e) {
        comps = e;
        return None;
      }
    );
    var e = engine.createEntity([CA]);
    Assert.same([CA], comps);
    e.addComponent(CB);
    Assert.same([CA, CB], comps);
    e.removeComponent(function(c) return c == CA);
    Assert.same([CB], comps);
  }

  public function testRemoveProperty() {
    var engine = Engine.withEnumProperty(),
        phase = engine.createPhase(),
        envs = null;
    phase.processProperties(
      function(e) {
        envs = e;
        return None;
      }
    );
    engine.addProperty(EA);
    Assert.same([EA], envs);
    engine.addProperty(EB);
    Assert.same([EA, EB], envs);
    engine.removeProperty(function(e) return e == EA);
    Assert.same([EB], envs);
  }
}
