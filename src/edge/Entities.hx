package edge;

import thx.ReadonlyArray;

@:access(edge.Engine.statusChange)
class Entities<Component, Property> {
  var entities: Array<Entity<Component>> = [];
  var engine: Engine<Component, Property>;

  public var length(get, never): Int;

  public function new(engine: Engine<Component, Property>) {
    this.engine = engine;
  }

  public function create(components: Array<Component>) {
    var entity = new Entity(components, cast engine.statusChange); // TODO cast?
    entities.push(entity);
    engine.statusChange(EntityCreated(entity));
    return entity;
  }

  inline function removeOne(entity: Entity<Component>)
    return entities.remove(entity);

  public function remove(predicate: Entity<Component> -> Bool) {
    for(entity in entities) {
      if(predicate(entity)) {
        entity.destroy();
        return true;
      }
    }
    return false;
  }

  public function removeAll(predicate: Entity<Component> -> Bool) {
    var removed = false;
    for(entity in entities) {
      if(predicate(entity)) {
        entity.destroy();
        removed = true;
      }
    }
    return removed;
  }

  public function clear() {
    removeAll(function(_) return true);
    return this;
  }

  public inline function get(): ReadonlyArray<Entity<Component>>
    return entities;

  inline function get_length()
    return entities.length;
}
