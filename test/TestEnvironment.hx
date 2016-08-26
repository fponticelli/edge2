import edge.TimeSpan;

import utest.Assert;
import edge.Engine;
using thx.Iterators;

class TestEnvironment {
  public function new() {}

  public function testBasics() {
    var engine = Engine.withEnumEnvironment();
    Assert.isFalse(engine.environments().hasNext());
    var s = Score({points: 1});
    engine.addEnvironment(s);
    Assert.equals(s, engine.environments().next());
    engine.addEnvironment(Player({name: "Edgy1"}));
    engine.addEnvironment(Player({name: "Edgy2"}));
    engine.addEnvironment(Player({name: "Edgy3"}));
    Assert.isTrue(engine.removeEnvironment(function(el) return switch el {
      case Player({ name: "Edgy1" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.environments().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.removeEnvironments(function(el) return switch el {
      case Player(_): true;
      case _: false;
    }));
    Assert.isFalse(engine.environments().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
  }
}

enum SampleEnvironment {
  Score(score: { points: Int });
  Player(info: { name: String });
}
