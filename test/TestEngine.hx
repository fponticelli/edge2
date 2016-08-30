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

class TestEngine {
  public function new() {}

  public function testPropagationAfterSystem() {
    var engine = Engine.withEnumEnvironment(),
        phase = engine.createPhase(),
        countComps = 0,
        countEnv = 0;
    phase.addView(
      View.componentsEnvironments(
        function(e) {
          countComps++;
          Assert.same(CA, e.next());
          return None;
        },
        function(e) {
          countEnv++;
          Assert.same(EA, e.next());
          return None;
        }
      )
    );
    Assert.equals(0, countComps);
    Assert.equals(0, countEnv);
    engine.createEntity([CA]);
    engine.addEnvironment(EA);
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
  }

  public function testPropagationBeforeSystem() {
    var engine = Engine.withEnumEnvironment(),
        phase = engine.createPhase(),
        countComps = 0,
        countEnv = 0;
    engine.createEntity([CA]);
    engine.addEnvironment(EA);
    phase.addView(
      View.componentsEnvironments(
        function(e) {
          countComps++;
          Assert.same(CA, e.next());
          return None;
        },
        function(e) {
          countEnv++;
          Assert.same(EA, e.next());
          return None;
        }
      )
    );
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
    engine.createEntity([CA]);
    engine.addEnvironment(EA);
    Assert.equals(2, countComps);
    Assert.equals(2, countEnv);
  }

  public function testPropagationAfterPhase() {
    var engine = Engine.withEnumEnvironment(),
        countComps = 0,
        countEnv = 0;
    engine.createEntity([CA]);
    engine.addEnvironment(EA);
    var phase = engine.createPhase();
    phase.addView(
      View.componentsEnvironments(
        function(e) {
          countComps++;
          Assert.same(CA, e.next());
          return None;
        },
        function(e) {
          countEnv++;
          Assert.same(EA, e.next());
          return None;
        }
      )
    );
    Assert.equals(1, countComps);
    Assert.equals(1, countEnv);
    engine.createEntity([CA]);
    engine.addEnvironment(EA);
    Assert.equals(2, countComps);
    Assert.equals(2, countEnv);
  }

  public function testAddRemoveComponent() {
    var engine = Engine.withEnumEnvironment(),
        phase = engine.createPhase(),
        comps = null;
    phase.addView(
      View.components(
        function(e) {
          comps = e.toArray();
          return None;
        }
      )
    );
    var e = engine.createEntity([CA]);
    Assert.same([CA], comps);
    e.addComponent(CB);
    Assert.same([CA, CB], comps);
    e.removeComponent(function(c) return c == CA);
    Assert.same([CB], comps);
  }

  public function testRemoveEnvironment() {
    var engine = Engine.withEnumEnvironment(),
        phase = engine.createPhase(),
        envs = null;
    phase.addView(
      View.environments(
        function(e) {
          envs = e.toArray();
          return None;
        }
      )
    );
    engine.addEnvironment(EA);
    Assert.same([EA], envs);
    engine.addEnvironment(EB);
    Assert.same([EA, EB], envs);
    engine.removeEnvironment(function(e) return e == EA);
    Assert.same([EB], envs);
  }
}
