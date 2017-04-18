import utest.Assert;
import edge.Entity;
import AComponent;

class TestComponents {
  var count: Int;
  var entity: Entity<AComponent>;
  public function new() {}

  public function setup() {
    count = 0;
    entity = new Entity([], statusChange);
  }

  public function statusChange<Component, Property>(_)
    count++;

  public function testBasics() {
    Assert.equals(0, count);
    entity.addComponent(CA);
    Assert.equals(CA, entity.components()[0]);
    Assert.equals(1, count);
    entity.addComponents([CB, CC]);
    var it = entity.components();
    Assert.equals(CA, it[0]);
    Assert.equals(CB, it[1]);
    Assert.equals(CC, it[2]);
    Assert.equals(2, count);
    entity.update(function(_) return [CA]);
    Assert.equals(CA, entity.components()[0]);
    Assert.equals(3, count);
  }

  public function testRemoveComponent() {
    entity.addComponents([CA, CB]);
    Assert.equals(1, count);
    Assert.isFalse(entity.removeComponent(function(v) return v == CC));
    Assert.equals(1, count);
    Assert.isTrue(entity.removeComponent(function(v) return v == CA));
    Assert.equals(2, count);
    Assert.equals(CB, entity.components()[0]);
  }

  public function testRemoveComponents() {
    entity.addComponents([CA, CB, CC]);
    Assert.equals(1, count);
    Assert.isFalse(entity.removeComponents(function(_) return false));
    Assert.equals(1, count);
    Assert.isTrue(entity.components().length > 0);
    Assert.isTrue(entity.removeComponents(function(_) return true));
    Assert.equals(2, count);
    Assert.isFalse(entity.components().length > 0);
  }
}
