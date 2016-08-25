package edge;

enum StatusChange<Component, Element> {
  ElementCreated(e: Element);
  ElementRemoved(e: Element);
  EntityCreated(e: Entity<Component, Element>);
  EntityUpdated(e: Entity<Component, Element>);
  EntityRemoved(e: Entity<Component, Element>);
}
