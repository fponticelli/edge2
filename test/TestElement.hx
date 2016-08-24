import edge.TimeSpan;

import utest.Assert;
import edge.Engine;
using thx.Iterators;

class TestElement {
  public function new() {}

  public function testBasics() {
    var engine = Engine.withEnumElement();
    Assert.isFalse(engine.elements().hasNext());
    var s = Score({points: 1});
    engine.addElement(s);
    Assert.equals(s, engine.elements().next());
    engine.addElement(Player({name: "Edgy1"}));
    engine.addElement(Player({name: "Edgy2"}));
    engine.addElement(Player({name: "Edgy3"}));
    Assert.isTrue(engine.removeElement(function(el) return switch el {
      case Player({ name: "Edgy1" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.elements().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
    Assert.isTrue(engine.removeElements(function(el) return switch el {
      case Player(_): true;
      case _: false;
    }));
    Assert.isFalse(engine.elements().any(function(el) return switch el {
      case Player({ name: "Edgy2" }): true;
      case _: false;
    }));
  }
}

enum SampleElement {
  Score(score: { points: Int });
  Player(info: { name: String });
}
