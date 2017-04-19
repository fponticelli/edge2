package edge;

import thx.ReadonlyArray;

@:access(edge.Engine.statusChange)
class Properties<Component, Property> {
  var properties: Array<Property> = [];
  var engine: Engine<Component, Property>;
  public var length(get, never): Int;
  public function new(engine: Engine<Component, Property>) {
    this.engine = engine;
  }

  public function add(property: Property) {
    properties.push(property); // TODO make sure it is unique?
    engine.statusChange(PropertyAdded(property));
  }

  function removeImpl(property) {
    properties.remove(property);
    engine.statusChange(PropertyRemoved(property));
  }

  public function removeOne(predicate: Property -> Bool): Bool {
    for(property in properties) {
      if(predicate(property)) {
        removeImpl(property);
        return true;
      }
    }
    return false;
  }

  public function remove(predicate: Property -> Bool): Bool {
    var removed = false;
    for(property in properties) {
      if(predicate(property)) {
        removeImpl(property);
        removed = true;
      }
    }
    return removed;
  }

  public function clear(): Engine<Component, Property> {
    remove(function(_) return true);
    return engine;
  }

  inline public function get(): ReadonlyArray<Property>
    return properties;

  inline function get_length(): Int
    return properties.length;
}
