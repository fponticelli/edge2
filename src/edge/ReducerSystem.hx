package edge;

class ReducerSystem<Payload> {
  var systems: Array<System<Payload>> = [];

  public function new() {}

  public function feed(system: System<Payload>): ReducerSystem<Payload> {
    systems.push(system);
    return this;
  }

  public function update(payload: Payload)
    for(system in systems)
      system(payload);
}
