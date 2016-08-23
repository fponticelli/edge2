package edge;

interface EntityView<T, Component, Message> {
  function onAddedEntity(entity: Entity<Component, Message>): Void;
  function onRemovedEntity(entity: Entity<Component, Message>): Void;
  function onUpdatedEntity(entity: Entity<Component, Message>): Void;

  function updateEntitySystem(system: EntitySystem<T, Component, Message>): Void;
}
