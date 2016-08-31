import utest.Assert;
import edge.Engine;

class TestEntity {
  public function new() {}

  public function testBasics() {
    var engine = Engine.withEnumProperty();
    Assert.isFalse(engine.entities().hasNext());
    var entity = engine.createEntity([]);
    Assert.isTrue(engine.entities().hasNext());
    Assert.notNull(entity);
    Assert.isFalse(entity.components().hasNext());
    Assert.isFalse(entity.destroyed);

    entity.destroy();
    Assert.isFalse(engine.entities().hasNext());
    Assert.isTrue(entity.destroyed);
  }

  public function testRemove() {
    var engine = Engine.withEnumProperty();
    var entity = engine.createEntity([]);
    engine.removeEntity(function(_) return false);
    Assert.isFalse(entity.destroyed);
    engine.removeEntity(function(_) return true);
    Assert.isFalse(engine.entities().hasNext());
    Assert.isTrue(entity.destroyed);
  }

  public function testRemoveMany() {
    var engine = Engine.withEnumProperty();
    var e1 = engine.createEntity([]);
    var e2 = engine.createEntity([]);
    engine.removeEntities(function(e) return e == e1);
    Assert.equals(e2, engine.entities().next());
  }
}
