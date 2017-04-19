package edge;

class Engine<Component, Property> {
  public var phases(default, null): Phases<Component, Property>;
  public var entities(default, null): Entities<Component, Property>;
  public var properties(default, null): Properties<Component, Property>;
  public function new() {
    phases = new Phases(this);
    entities = new Entities(this);
    properties = new Properties(this);
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
      phase.dispatch(change);
    }
  }

  public function clear(): Void {
    entities.clear();
    properties.clear();
  }
}
