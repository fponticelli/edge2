package edge;

interface MessageSystem<T, Component, Message> extends System<Component, Message> {
  function update(value: T): Void;
}
