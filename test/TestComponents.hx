import edge.TimeSpan;

import utest.Assert;
import edge.Entity;
using thx.Iterators;
import thx.Nil;

class TestComponents {
  var count: Int;
  var entity: Entity<TestComponent, Nil>;
  public function new() {}

  public function setup() {
    count = 0;
    entity = new Entity(entityUpdated);
  }

  public function entityUpdated<Component, Element>(e: Entity<Component, Element>, _)
    count++;

  public function testBasics() {
    Assert.equals(0, count);
    entity.addComponent(A);
    Assert.equals(A, entity.components().next());
    Assert.equals(1, count);
    entity.addComponents([B, C]);
    var it = entity.components();
    Assert.equals(A, it.next());
    Assert.equals(B, it.next());
    Assert.equals(C, it.next());
    Assert.equals(2, count);
    entity.update(function(_) return [A]);
    Assert.equals(A, entity.components().next());
    Assert.equals(3, count);
// removeComponent
// removeComponents
  }

  public function testRemoveComponent() {
    entity.addComponents([A, B]);
    Assert.equals(1, count);
    Assert.isFalse(entity.removeComponent(function(v) return v == C));
    Assert.equals(1, count);
    Assert.isTrue(entity.removeComponent(function(v) return v == A));
    Assert.equals(2, count);
    Assert.equals(B, entity.components().next());
  }

  public function testRemoveComponents() {
    entity.addComponents([A, B, C]);
    Assert.equals(1, count);
    Assert.isFalse(entity.removeComponents(function(_) return false));
    Assert.equals(1, count);
    Assert.isTrue(entity.components().hasNext());
    Assert.isTrue(entity.removeComponents(function(_) return true));
    Assert.equals(2, count);
    Assert.isFalse(entity.components().hasNext());
  }
}

enum TestComponent {
  A;
  B;
  C;
}
