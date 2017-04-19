package edge;

import thx.Maybe;
import thx.OrderedMap;
import thx.ReadonlyArray;

interface Processor<Payload, Component, Property> {
  public function onChange(change: StatusChange<Component, Property>): Void;
  public function payload(): Maybe<Payload>;
}

class ComponentsAndPropertyProcessor<ComponentsPayload, PropertyPayload, Payload, Component, Property> implements Processor<Payload, Component, Property> {
  var _payload: Maybe<Payload> = null;
  var processorComponents: Processor<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var processorProperty: Processor<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(phase: Phase<Component, Property>, matchEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>, matchProperty: Property -> Maybe<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.processorComponents = new ComponentProcessor(matchEntity);
    this.processorProperty = new PropertyProcessor(matchProperty);
    this.compose = compose;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    processorComponents.onChange(change);
    processorProperty.onChange(change);
    _payload = switch [processorComponents.payload(), processorProperty.payload()] {
      case [null, null] | [_, null] | [null, _]: Maybe.none();
      case [c, e]: Maybe.of(compose(c.get(), e.get()));
    };
  }

  public function payload(): Maybe<Payload> return _payload;
}

class ComponentsAndPropertiesProcessor<ComponentsPayload, PropertyPayload, Payload, Component, Property> implements Processor<Payload, Component, Property> {
  var _payload: Maybe<Payload> = null;
  var processorComponents: Processor<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var processorProperty: Processor<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(phase: Phase<Component, Property>, matchEntity: ReadonlyArray<Component> -> Maybe<ComponentsPayload>, matchProperty: ReadonlyArray<Property> -> Maybe<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.processorComponents = new ComponentProcessor(matchEntity);
    this.processorProperty = new PropertiesProcessor(matchProperty);
    this.compose = compose;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    processorComponents.onChange(change);
    processorProperty.onChange(change);
    _payload = switch [processorComponents.payload(), processorProperty.payload()] {
      case [null, null] | [_, null] | [null, _]: null;
      case [c, e]: Maybe.of(compose(c.get(), e.get()));
    }
  }

  public function payload(): Maybe<Payload> return _payload;
}

class PropertyProcessor<Payload, Component, Property> implements Processor<Payload, Component, Property> {
  var _payload: Maybe<Payload> = null;
  var matchProperty: Property -> Maybe<Payload>;
  public function new(matchProperty: Property -> Maybe<Payload>) {
    this.matchProperty = matchProperty;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case PropertyAdded(e):
        _payload = matchProperty(e);
      case PropertyRemoved(e):
        _payload = Maybe.none();
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  public function payload(): Maybe<Payload> return _payload;
}

class PropertiesProcessor<Payload, Component, Property> implements Processor<Payload, Component, Property> {
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
        switch matchProperties(properties) {
          case null:
          case v: _payload = v;
        }
      case PropertyRemoved(e):
        properties.remove(e);
        switch matchProperties(properties) {
          case null:
          case v: _payload = v;
        }
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  public function payload(): Maybe<Payload> return _payload;
}

class ComponentProcessor<Payload, Component, Property> implements Processor<ReadonlyArray<ItemEntity<Payload, Component>>, Component, Property> {
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
          map.set(e, { data: p.get(), entity: e });
        }
      case EntityUpdated(e):
        var p = matchEntity(e.components());
        if(p.hasValue()) {
          map.set(e, { data: p.get(), entity: e });
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

typedef ItemEntity<ItemPayload, Component> = {
  data: ItemPayload,
  entity: Entity<Component>
}
