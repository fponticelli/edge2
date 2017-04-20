package edge;

import thx.Maybe;
import thx.OrderedMap;
import thx.ReadonlyArray;

interface Reducer<Payload, Component, Property> {
  public function onChange(change: StatusChange<Component, Property>): Void;
  public function payload(): Maybe<Payload>;
}

class ComponentsAndPropertyReducer<ComponentsPayload, PropertyPayload, Payload, Component, Property> implements Reducer<Payload, Component, Property> {
  var _payload: Maybe<Payload> = null;
  var reducerComponents: Reducer<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var reducerProperty: Reducer<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(phase: Phase<Component, Property>, matchEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>, matchProperty: Property -> Maybe<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.reducerComponents = new ComponentReducer(matchEntity);
    this.reducerProperty = new PropertyReducer(matchProperty);
    this.compose = compose;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    reducerComponents.onChange(change);
    reducerProperty.onChange(change);
    _payload = switch [reducerComponents.payload(), reducerProperty.payload()] {
      case [null, null] | [_, null] | [null, _]: Maybe.none();
      case [c, e]: Maybe.of(compose(c.getUnsafe(), e.getUnsafe()));
    };
  }

  public function payload(): Maybe<Payload> return _payload;
}

class ComponentsAndPropertiesReducer<ComponentsPayload, PropertyPayload, Payload, Component, Property> implements Reducer<Payload, Component, Property> {
  var _payload: Maybe<Payload> = null;
  var reducerComponents: Reducer<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var reducerProperty: Reducer<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(phase: Phase<Component, Property>, matchEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>, matchProperty: ReadonlyArray<Property> -> Maybe<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.reducerComponents = new ComponentReducer(matchEntity);
    this.reducerProperty = new PropertiesReducer(matchProperty);
    this.compose = compose;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    reducerComponents.onChange(change);
    reducerProperty.onChange(change);
    _payload = switch [reducerComponents.payload(), reducerProperty.payload()] {
      case [null, null] | [_, null] | [null, _]: Maybe.none();
      case [c, e]: Maybe.of(compose(c.getUnsafe(), e.getUnsafe()));
    }
  }

  public function payload(): Maybe<Payload> return _payload;
}

class PropertyReducer<Payload, Component, Property> implements Reducer<Payload, Component, Property> {
  var _payload: Maybe<Payload> = null;
  var matchProperty: Property -> Maybe<Payload>;
  public function new(matchProperty: Property -> Maybe<Payload>) {
    this.matchProperty = matchProperty;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case PropertyAdded(e):
        var maybe = matchProperty(e);
        if(maybe.hasValue())
          _payload = maybe;
      case PropertyRemoved(e) if(matchProperty(e).hasValue()):
        _payload = Maybe.none();
      case PropertyRemoved(_), EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  public function payload(): Maybe<Payload> return _payload;
}

class PropertiesReducer<Payload, Component, Property> implements Reducer<Payload, Component, Property> {
  var matchProperties: ReadonlyArray<Property> -> Maybe<Payload>;
  var properties: Array<Property>;
  var _payload: Maybe<Payload> = null;
  public function new(matchProperties: ReadonlyArray<Property> -> Maybe<Payload>) {
    this.matchProperties = matchProperties;
    properties = [];
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case PropertyAdded(e):
        properties.push(e);
        var maybe = matchProperties(properties);
        if(maybe.hasValue())
          _payload = maybe;
      case PropertyRemoved(e):
        properties.remove(e);
        _payload = matchProperties(properties);
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  public function payload(): Maybe<Payload> return _payload;
}

class ComponentReducer<Payload, Component, Property> implements Reducer<ReadonlyArray<ItemEntity<Payload, Component>>, Component, Property> {
  var map: OrderedMap<Entity<Component>, ItemEntity<Payload, Component>>;
  var matchEntity: ReadonlyArray<Component> -> Maybe<Payload>;
  public function new(matchEntity: ReadonlyArray<Component> -> Maybe<Payload>) {
    map = OrderedMap.createObject();
    this.matchEntity = matchEntity;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case EntityCreated(e):
        var p = matchEntity(e.components());
        if(p.hasValue()) {
          map.set(e, { data: p.getUnsafe(), entity: e });
        }
      case EntityUpdated(e):
        var p = matchEntity(e.components());
        if(p.hasValue()) {
          map.set(e, { data: p.getUnsafe(), entity: e });
        } else {
          map.remove(e);
        }
      case EntityRemoved(e):
        map.remove(e);
      case PropertyAdded(e): // do nothing
      case PropertyRemoved(e): // do nothing
    }
  }

  public function payload(): Maybe<ReadonlyArray<ItemEntity<Payload, Component>>>
    return if(map.length == 0) Maybe.none() else Maybe.of(map.toArray());
}
