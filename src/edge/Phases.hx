package edge;

import thx.ReadonlyArray;

class Phases<Component, Property> {
  var phases: Array<Phase<Component, Property>> = [];
  var engine: Engine<Component, Property>;

  public function new(engine: Engine<Component, Property>) {
    this.engine = engine;
  }

  public function create(): Phase<Component, Property> {
    var phase = new Phase(engine);
    phases.push(phase);
    return phase;
  }

  public inline function get(): ReadonlyArray<Phase<Component, Property>>
    return phases;
}

