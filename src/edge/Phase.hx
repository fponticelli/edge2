package edge;

import haxe.ds.Option;
import thx.Any;

class Phase<Component, Environment> {
  var _views: Map<View<Dynamic, Component, Environment>, ViewSystem<Dynamic>> = new Map(); // Dynamic should be Any
  public function new() {}

  public function addView<Payload>(view: View<Payload, Component, Environment>): ViewSystem<Payload> {
    var viewSystem = _views.get(view);
    if(null == viewSystem) {
      _views.set(view, viewSystem = new ViewSystem());
    }
    // TODO
    return cast viewSystem;
  }

  public function update() {
    for(view in _views.keys()) {
      switch view.payload() {
        case None: continue;
        case Some(pl):
          var viewSystem = _views.get(view);
          viewSystem.update(pl);
      }
    }
  }

  public function propagate(change: StatusChange<Component, Environment>) {
    for(view in _views.keys())
      view.onChange(change);
  }
}
