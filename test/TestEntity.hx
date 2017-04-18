import utest.Assert;
import edge.Engine;

class TestEntity {
  public function new() {}

  public function testBasics() {
    var engine = Engine.withEnumProperty();
    Assert.isFalse(engine.entities.length > 0);
    var entity = engine.entities.create([]);
    Assert.isTrue(engine.entities.length > 0);
    Assert.notNull(entity);
    Assert.isFalse(entity.components().length > 0);
    Assert.isFalse(entity.destroyed);

    entity.destroy();
    Assert.isFalse(engine.entities.length > 0);
    Assert.isTrue(entity.destroyed);
  }

  public function testRemove() {
    var engine = Engine.withEnumProperty();
    var entity = engine.entities.create([]);
    engine.entities.remove(function(_) return false);
    Assert.isFalse(entity.destroyed);
    engine.entities.remove(function(_) return true);
    Assert.isFalse(engine.entities.length > 0);
    Assert.isTrue(entity.destroyed);
  }

  public function testRemoveMany() {
    var engine = Engine.withEnumProperty();
    var e1 = engine.entities.create([]);
    var e2 = engine.entities.create([]);
    engine.entities.remove(function(e) return e == e1);
    Assert.equals(e2, engine.entities.get()[0]);
  }
}
