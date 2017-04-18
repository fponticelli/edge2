package edge;

import thx.ReadonlyArray;
import thx.Set;

class Engine<Component, Property> {
  public static function withEnumProperty<C, P: EnumValue>(): Engine<C, P>
    return new Engine(Set.createEnum());

  public var phases(default, null): Phases<Component, Property>;
  public var entities(default, null): Entities<Component, Property>;
  public function new(properties: Set<Property>) {
    phases = new Phases(this);
    entities = new Entities(this);
    propertySet = properties;
  }

  @:access(edge.Entities.removeOne)
  function statusChange(change: StatusChange<Component, Property>) {
    switch change {
      case EntityRemoved(e):
        entities.removeOne(e);
      case _:
        // do nothing
    }
    for(phase in phases.get()) {
      phase.propagate(change);
    }
  }

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
    entities.clear();
    clearProperties();
  }
}
