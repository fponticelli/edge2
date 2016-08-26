package edge;

enum StatusChange<Component, Environment> {
  EnvironmentCreated(e: Environment);
  EnvironmentRemoved(e: Environment);
  EntityCreated(e: Entity<Component, Environment>);
  EntityUpdated(e: Entity<Component, Environment>);
  EntityRemoved(e: Entity<Component, Environment>);
}
