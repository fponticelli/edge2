package edge;

import haxe.ds.Option;

class Phase<Component, Element> {
  public function addComponentSystem<T>(view: EntityView<T, Component, Element>, system: EntitySystem<T, Component, Element>): Void {
    return throw new thx.error.NotImplemented();
  }
  public function addElementSystem<T>(view: ElementView<T, Component, Element>, system: ElementSystem<T, Component, Element>): Void {
    return throw new thx.error.NotImplemented();
  }
  public function addSystem<T>(view: View<T, Component, Element>, system: System<Component, Element>): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeSystem<T>(system: System<Component, Element>): Void {
    return throw new thx.error.NotImplemented();
  }
}
