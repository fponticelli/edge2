package edge;

import haxe.ds.Option;

class Phase<Component, Element> {
  public function addView<Payload>(view: View<Payload, Component, Element>): ViewSystem<Payload, Component, Element> {
    return throw new thx.error.NotImplemented();
  }
}
