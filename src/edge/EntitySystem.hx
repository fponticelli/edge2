package edge;

interface EntitySystem<T, Component, Message> extends System<Component, Message> {
  function each(value: T): Void;
  function after(): Void;
}
