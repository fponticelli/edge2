package edge;

class Entity<Component, Message> {
  public function addComponent(c: Component): Void {
    return throw new thx.error.NotImplemented();
  }
  public function addComponents(cs: Iterable<Component>): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeComponents(predicate: Component -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeComponent(predicate: Component -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function isDestroyed(): Void {
    return throw new thx.error.NotImplemented();
  }
  public function destroy(): Void {
    return throw new thx.error.NotImplemented();
  }
  public function all(predicate: Component -> Bool): Bool {
    return throw new thx.error.NotImplemented();
  }
  public function any(predicate: Component -> Bool): Bool {
    return throw new thx.error.NotImplemented();
  }
  public function components(): Iterable<Component> {
    return throw new thx.error.NotImplemented();
  }

  // maybe?
  public var engine: Engine<Component, Message>;
}
