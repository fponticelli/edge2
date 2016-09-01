package edge;

import edge.Processor;
import haxe.ds.Option;
import thx.Any;
import thx.ReadonlyArray;

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

  public function processComponents<Payload>(extractor: ReadonlyArray<Component> -> Option<Payload>): ProcessorSystem<ReadonlyArray<ItemEntity<Payload, Component>>>
    return addProcessor(new ComponentProcessor(extractor));
  public function processProperty<Payload>(extractor: Property -> Option<Payload>): ProcessorSystem<Payload>
    return addProcessor(new PropertyProcessor(extractor));
  public function processProperties<Payload>(extractor: ReadonlyArray<Property> -> Option<Payload>): ProcessorSystem<Payload>
    return addProcessor(new PropertiesProcessor(extractor));
  public function processComponentsProperty<ComponentsPayload, PropertyPayload, Payload>(
    extractorEntity: ReadonlyArray<Component> -> Option<ComponentsPayload>,
    extractorProperty: Property -> Option<PropertyPayload>
  ): ProcessorSystem<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }>
    return addProcessor(new ComponentsAndPropertyProcessor(this, extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    }));
  public function processComponentsProperties<ComponentsPayload, PropertyPayload, Payload>(
    extractorEntity: ReadonlyArray<Component> -> Option<ComponentsPayload>,
    extractorProperty: ReadonlyArray<Property> -> Option<PropertyPayload>
  ): ProcessorSystem<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }>
    return addProcessor(new ComponentsAndPropertiesProcessor(this, extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    }));

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
