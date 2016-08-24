package edge;

interface EntitySystem<T, Component, Element> extends System<Component, Element> {
  function each(value: T): Void;
  function after(): Void;
}
