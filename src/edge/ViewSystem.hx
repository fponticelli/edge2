package edge;

class ViewSystem<Payload> {
  var _systems: Array<System<Payload>> = [];

  public function new() {}

  public function with(system: System<Payload>): ViewSystem<Payload> {
    this._systems.push(system);
    return this;
  }

  public function update(payload: Payload)
    for(system in _systems)
      system(payload);
}
