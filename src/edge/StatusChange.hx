package edge;

enum StatusChange<Component, Property> {
  PropertyAdded(e: Property);
  PropertyRemoved(e: Property);
  EntityCreated(e: Entity<Component>);
  EntityUpdated(e: Entity<Component>);
  EntityRemoved(e: Entity<Component>);
}
