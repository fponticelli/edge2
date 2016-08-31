package edge;

class ProcessorSystem<Payload> {
  var systems: Array<System<Payload>> = [];

  public function new() {}

  public function with(system: System<Payload>): ProcessorSystem<Payload> {
    systems.push(system);
    return this;
  }

  public function update(payload: Payload)
    for(system in systems)
      system(payload);
}
