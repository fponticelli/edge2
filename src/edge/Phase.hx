package edge;

import edge.Reducer;
import thx.Maybe;
import thx.ReadonlyArray;

class Phase<Component, Property> {
  var reducers: Map<Reducer<Dynamic, Component, Property>, ReducerSystem<Dynamic>> = new Map(); // Dynamic should be Any
  public var engine(default, null): Engine<Component, Property>;
  public function new(engine: Engine<Component, Property>) {
    this.engine = engine;
  }

  public function addReducer<Payload>(reducer: Reducer<Payload, Component, Property>): ReducerSystem<Payload> {
    var reducerSystem = reducers.get(reducer);
    if(null == reducerSystem) {
      reducers.set(reducer, reducerSystem = new ReducerSystem());
    }
    if(null != engine) {
      for(e in engine.properties.get())
        reducer.onChange(PropertyAdded(e));
      for(e in engine.entities.get())
        reducer.onChange(EntityCreated(e));
    }
    return cast reducerSystem; // TODO cast?
  }

  public function reduceComponents<Payload>(extractor: ReadonlyArray<Component> -> Maybe<Payload>): ReducerSystem<ReadonlyArray<ItemEntity<Payload, Component>>>
    return addReducer(new ComponentReducer(extractor));

  public function reduceProperty<Payload>(extractor: Property -> Maybe<Payload>): ReducerSystem<Payload>
    return addReducer(new PropertyReducer(extractor));

  public function reduceProperties<Payload>(extractor: ReadonlyArray<Property> -> Maybe<Payload>): ReducerSystem<Payload>
    return addReducer(new PropertiesReducer(extractor));

  public function reduceComponentsProperty<ComponentsPayload, PropertyPayload, Payload>(
    extractorEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>,
    extractorProperty: Property -> Maybe<PropertyPayload>
  ): ReducerSystem<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }>
    return addReducer(new ComponentsAndPropertyReducer(this, extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    }));

  public function reduceComponentsProperties<ComponentsPayload, PropertyPayload, Payload>(
    extractorEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>,
    extractorProperty: ReadonlyArray<Property> -> Maybe<PropertyPayload>
  ): ReducerSystem<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }>
    return addReducer(new ComponentsAndPropertiesReducer(this, extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    }));

  public function update() {
    for(reducer in reducers.keys()) {
      switch reducer.payload() {
        case null: continue;
        case pl:
          var reducerSystem = reducers.get(reducer);
          reducerSystem.update(pl);
      }
    }
  }

  public function dispatch(change: StatusChange<Component, Property>) {
    for(reducer in reducers.keys())
      reducer.onChange(change);
  }
}
