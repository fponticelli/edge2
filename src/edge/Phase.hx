package edge;

import haxe.ds.Option;

class Phase<Component, Message> {
  public function addComponentSystem<T>(view: EntityView<T, Component, Message>, system: EntitySystem<T, Component, Message>): Void {
    return throw new thx.error.NotImplemented();
  }
  public function addMessageSystem<T>(view: MessageView<T, Component, Message>, system: MessageSystem<T, Component, Message>): Void {
    return throw new thx.error.NotImplemented();
  }
  public function addSystem<T>(view: View<T, Component, Message>, system: System<Component, Message>): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeSystem<T>(system: System<Component, Message>): Void {
    return throw new thx.error.NotImplemented();
  }
}
