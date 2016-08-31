package edge;

enum StatusChange<Component, Environment> {
  EnvironmentAdded(e: Environment);
  EnvironmentRemoved(e: Environment);
  EntityCreated(e: Entity<Component>);
  EntityUpdated(e: Entity<Component>);
  EntityRemoved(e: Entity<Component>);
}
