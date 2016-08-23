package edge;

interface MessageView<T, Component, Message> {
  function onAddedMessage(message: Message): Void;
  function onRemovedMessage(message: Message): Void;

  function updateMessageSystem(system: MessageSystem<T, Component, Message>): Void;
}
