package edge;

interface View<Payload, Component, Element> {
  function onAddedElement(Element: Element): Void;
  function onRemovedElement(Element: Element): Void;
  function onAddedEntity(entity: Entity<Component, Element>): Void;
  function onRemovedEntity(entity: Entity<Component, Element>): Void;
  function onUpdatedEntity(entity: Entity<Component, Element>): Void;
  function updateSystem(system: System<Payload, Component, Element>): Void;
}
