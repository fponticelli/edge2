package edge;

import haxe.ds.Option;
import thx.Any;

class Phase<Component, Property> {
  var processors: Map<Processor<Dynamic, Component, Property>, ProcessorSystem<Dynamic>> = new Map(); // Dynamic should be Any
  public var engine(default, null): Engine<Component, Property>;
  public function new(engine: Engine<Component, Property>) {
    this.engine = engine;
  }

  public function addProcessor<Payload>(view: Processor<Payload, Component, Property>): ProcessorSystem<Payload> {
    var viewSystem = processors.get(view);
    if(null == viewSystem) {
      processors.set(view, viewSystem = new ProcessorSystem());
    }
    if(null != engine) {
      for(e in engine.properties())
        view.onChange(PropertyAdded(e));
      for(e in engine.entities())
        view.onChange(EntityCreated(e));
    }
    return cast viewSystem;
  }

  public function update() {
    for(view in processors.keys()) {
      switch view.payload() {
        case None: continue;
        case Some(pl):
          var viewSystem = processors.get(view);
          viewSystem.update(pl);
      }
    }
  }

  public function propagate(change: StatusChange<Component, Property>) {
    for(view in processors.keys())
      view.onChange(change);
  }
}
