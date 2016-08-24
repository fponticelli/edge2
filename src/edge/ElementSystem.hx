package edge;

interface ElementSystem<T, Component, Element> extends System<Component, Element> {
  function update(value: T): Void;
}
