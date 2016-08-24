package edge;

interface EntityView<T, Component, Element> {
  function onAddedEntity(entity: Entity<Component, Element>): Void;
  function onRemovedEntity(entity: Entity<Component, Element>): Void;
  function onUpdatedEntity(entity: Entity<Component, Element>): Void;

  function updateEntitySystem(system: EntitySystem<T, Component, Element>): Void;
}
