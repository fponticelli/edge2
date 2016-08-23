package edge;

class Engine<Component, Message> {
  // phases
  public function createPhase(): Phase<Component, Message> {
    return throw new thx.error.NotImplemented();
  }
  public function phases(): Iterable<Phase<Component, Message>> { // ?
    return throw new thx.error.NotImplemented();
  }

  // entities
  public function createEntity(components: Iterable<Component>): Entity<Component, Message> {
    return throw new thx.error.NotImplemented();
  }
  public function removeEntity(predicate: Entity<Component, Message> -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeEntities(predicate: Entity<Component, Message> -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function clearEntities(): Void {
    return throw new thx.error.NotImplemented();
  }

  // messages
  public function addMessage(message: Message): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeMessage(predicate: Message -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeMessages(predicate: Message -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function clearMessages(): Void {
    return throw new thx.error.NotImplemented();
  }


  public function clear(): Void {
    return throw new thx.error.NotImplemented();
  }
}
