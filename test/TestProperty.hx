import edge.TimeSpan;

import utest.Assert;
import edge.Engine;
using thx.Iterators;

class TestProperty {
  public function new() {}

  public function testBasics() {
    var engine = Engine.withEnumProperty();
    Assert.isFalse(engine.properties().hasNext());
    var s = Score({points: 1});
    engine.addProperty(s);
    Assert.equals(s, engine.properties().next());
    engine.addProperty(Player({name: "Edgy1"}));
    engine.addProperty(Player({name: "Edgy2"}));
    engine.addProperty(Player({name: "Edgy3"}));
    Assert.isTrue(engine.removeProperty(function(el) return switch el {
      case Player({ name: "Edgy1" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.properties().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.removeProperties(function(el) return switch el {
      case Player(_): true;
      case _: false;
    }));
    Assert.isFalse(engine.properties().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
  }
}

enum SampleProperty {
  Score(score: { points: Int });
  Player(info: { name: String });
}
