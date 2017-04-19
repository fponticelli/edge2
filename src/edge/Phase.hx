package edge;

import edge.Processor;
import thx.Maybe;
import thx.ReadonlyArray;

class Phase<Component, Property> {
  var processors: Map<Processor<Dynamic, Component, Property>, ProcessorSystem<Dynamic>> = new Map(); // Dynamic should be Any
  public var engine(default, null): Engine<Component, Property>;
  public function new(engine: Engine<Component, Property>) {
    this.engine = engine;
  }

  public function addProcessor<Payload>(processor: Processor<Payload, Component, Property>): ProcessorSystem<Payload> {
    var processorSystem = processors.get(processor);
    if(null == processorSystem) {
      processors.set(processor, processorSystem = new ProcessorSystem());
    }
    if(null != engine) {
      for(e in engine.properties.get())
        processor.onChange(PropertyAdded(e));
      for(e in engine.entities.get())
        processor.onChange(EntityCreated(e));
    }
    return cast processorSystem; // TODO cast?
  }

  public function processComponents<Payload>(extractor: ReadonlyArray<Component> -> Maybe<Payload>): ProcessorSystem<ReadonlyArray<ItemEntity<Payload, Component>>>
    return addProcessor(new ComponentProcessor(extractor));

  public function processProperty<Payload>(extractor: Property -> Maybe<Payload>): ProcessorSystem<Payload>
    return addProcessor(new PropertyProcessor(extractor));

  public function processProperties<Payload>(extractor: ReadonlyArray<Property> -> Maybe<Payload>): ProcessorSystem<Payload>
    return addProcessor(new PropertiesProcessor(extractor));

  public function processComponentsProperty<ComponentsPayload, PropertyPayload, Payload>(
    extractorEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>,
    extractorProperty: Property -> Maybe<PropertyPayload>
  ): ProcessorSystem<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }>
    return addProcessor(new ComponentsAndPropertyProcessor(this, extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    }));

  public function processComponentsProperties<ComponentsPayload, PropertyPayload, Payload>(
    extractorEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>,
    extractorProperty: ReadonlyArray<Property> -> Maybe<PropertyPayload>
  ): ProcessorSystem<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }>
    return addProcessor(new ComponentsAndPropertiesProcessor(this, extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    }));

  public function update() {
    for(processor in processors.keys()) {
      switch processor.payload() {
        case null: continue;
        case pl:
          var processorSystem = processors.get(processor);
          processorSystem.update(pl);
      }
    }
  }

  public function dispatch(change: StatusChange<Component, Property>) {
    for(processor in processors.keys())
      processor.onChange(change);
  }
}
