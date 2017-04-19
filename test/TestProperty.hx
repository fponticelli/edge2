import utest.Assert;
import edge.Engine;
using thx.Arrays;

class TestProperty {
  public function new() {}

  public function testBasics() {
    var engine = new Engine();
    Assert.isFalse(engine.properties.length > 0);
    var s = Score({points: 1});
    engine.properties.add(s);
    Assert.equals(s, engine.properties.get()[0]);
    engine.properties.add(Player({name: "Edgy1"}));
    engine.properties.add(Player({name: "Edgy2"}));
    engine.properties.add(Player({name: "Edgy3"}));
    Assert.isTrue(engine.properties.remove(function(el) return switch el {
      case Player({ name: "Edgy1" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.properties.get().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.properties.remove(function(el) return switch el {
      case Player(_): true;
      case _: false;
    }));
    Assert.isFalse(engine.properties.get().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
  }
}

enum SampleProperty {
  Score(score: { points: Int });
  Player(info: { name: String });
}
