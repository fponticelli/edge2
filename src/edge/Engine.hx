package edge;

import thx.Set;
import edge.Entity;

class Engine<Component, Property> {
  public static function withEnumProperty<Component, Property : EnumValue>(): Engine<Component, Property>
    return new Engine(function(): Set<Property> return cast Set.createEnum());

  public function new(createPropertySet : Void -> Set<Property>) {
    _entities = Set.createObject();
    _properties = createPropertySet();
  }

  // phases
  var _phases: Array<Phase<Component, Property>> = [];
  public function createPhase(): Phase<Component, Property> {
    var phase = new Phase(this);
    _phases.push(phase);
    return phase;
  }
  public function phases(): Array<Phase<Component, Property>>
    return _phases;

  // entities
  var _entities: Set<Entity<Component>>;
  public function createEntity(components: Array<Component>): Entity<Component> {
    var entity = new Entity(components, cast statusChange);
    _entities.add(entity);
    statusChange(EntityCreated(entity));
    return entity;
  }

  public function removeEntity(predicate: Entity<Component> -> Bool): Bool {
    for(entity in _entities) {
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
        _entities.remove(e);
      case _:
        // do nothing
    }
    for(phase in _phases) {
      phase.propagate(change);
    }
  }

  public function removeEntities(predicate: Entity<Component> -> Bool): Bool {
    var removed = false;
    for(entity in _entities) {
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

  public function entities(): Array<Entity<Component>>
    return _entities.toArray();

  // properties
  var _properties: Set<Property>;
  public function addProperty(property: Property): Void {
    _properties.add(property);
    statusChange(PropertyAdded(property));
  }

  function _removeProperty(property) {
    _properties.remove(property);
    statusChange(PropertyRemoved(property));
  }

  public function removeProperty(predicate: Property -> Bool): Bool {
    for(property in _properties) {
      if(predicate(property)) {
        _removeProperty(property);
        return true;
      }
    }
    return false;
  }
  public function removeProperties(predicate: Property -> Bool): Bool {
    var removed = false;
    for(property in _properties) {
      if(predicate(property)) {
        _removeProperty(property);
        removed = true;
      }
    }
    return removed;
  }
  public function clearProperties(): Engine<Component, Property> {
    removeProperties(function(_) return true);
    return this;
  }

  public function properties(): Array<Property> // TODO this is supposed to be a ReadonlyArray
    return _properties;

  public function clear(): Void {
    clearEntities();
    clearProperties();
  }
}
