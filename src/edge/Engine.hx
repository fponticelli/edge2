package edge;

import thx.ReadonlyArray;
import thx.Set;
import edge.Entity;

class Engine<Component, Property> {
  public static function withEnumProperty<C, P: EnumValue>(): Engine<C, P>
    return new Engine(Set.createEnum());

  public function new(properties: Set<Property>) {
    entitySet = Set.createObject();
    propertySet = properties;
  }

  // phases
  var _phases: Array<Phase<Component, Property>> = [];
  public function createPhase(): Phase<Component, Property> {
    var phase = new Phase(this);
    _phases.push(phase);
    return phase;
  }
  public var phases(get, never): ReadonlyArray<Phase<Component, Property>>;
  function get_phases()
    return _phases;

  // entities
  var entitySet: Set<Entity<Component>>;
  public function createEntity(components: Array<Component>): Entity<Component> {
    var entity = new Entity(components, cast statusChange);
    entitySet.add(entity);
    statusChange(EntityCreated(entity));
    return entity;
  }

  public function removeEntity(predicate: Entity<Component> -> Bool): Bool {
    for(entity in entitySet) {
      if(predicate(entity)) {
        entity.destroy();
        return true;
      }
    }
    return false;
  }

  function statusChange(change: StatusChange<Component, Property>) {
    switch change {
      case EntityRemoved(e):
        entitySet.remove(e);
      case _:
        // do nothing
    }
    for(phase in _phases) {
      phase.propagate(change);
    }
  }

  public function removeEntities(predicate: Entity<Component> -> Bool): Bool {
    var removed = false;
    for(entity in entitySet) {
      if(predicate(entity)) {
        entity.destroy();
        removed = true;
      }
    }
    return removed;
  }

  public function clearEntities(): Engine<Component, Property> {
    removeEntities(function(_) return true);
    return this;
  }

  public var entities(get, never): ReadonlyArray<Entity<Component>>;
  function get_entities()
    return entitySet.toArray();

  // properties
  var propertySet: Set<Property>;
  public function addProperty(property: Property): Void {
    propertySet.add(property);
    statusChange(PropertyAdded(property));
  }

  function removePropertyImpl(property) {
    propertySet.remove(property);
    statusChange(PropertyRemoved(property));
  }

  public function removeProperty(predicate: Property -> Bool): Bool {
    for(property in propertySet) {
      if(predicate(property)) {
        removePropertyImpl(property);
        return true;
      }
    }
    return false;
  }
  public function removeProperties(predicate: Property -> Bool): Bool {
    var removed = false;
    for(property in propertySet) {
      if(predicate(property)) {
        removePropertyImpl(property);
        removed = true;
      }
    }
    return removed;
  }
  public function clearProperties(): Engine<Component, Property> {
    removeProperties(function(_) return true);
    return this;
  }

  public var properties(get, never): ReadonlyArray<Property>;
  function get_properties()
    return propertySet.toArray();

  public function clear(): Void {
    clearEntities();
    clearProperties();
  }
}
