package edge;

import haxe.ds.Option;

class Phase<Component, Element> {
  public function new() {}

  public function addView<Payload>(view: View<Payload, Component, Element>): ViewSystem<Payload> {
    return throw new thx.error.NotImplemented();
  }

  public function update() {
    return throw new thx.error.NotImplemented();
  }
}
