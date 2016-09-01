package edge;

import haxe.ds.Option;
import thx.OrderedMap;
import thx.ReadonlyArray;

interface Processor<Payload, Component, Property> {
  public function onChange(change: StatusChange<Component, Property>): Void;
  public function payload(): Option<Payload>;
}

class ComponentsAndPropertyProcessor<ComponentsPayload, PropertyPayload, Payload, Component, Property> implements Processor<Payload, Component, Property> {
  var _payload = None;
  var processorComponents: Processor<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var processorProperty: Processor<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(phase: Phase<Component, Property>, matchEntity: Iterator<Component> -> Option<ComponentsPayload>, matchProperty: Property -> Option<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.processorComponents = new ComponentProcessor(matchEntity);
    this.processorProperty = new PropertyProcessor(matchProperty);
    this.compose = compose;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    processorComponents.onChange(change);
    processorProperty.onChange(change);
    _payload = switch [processorComponents.payload(), processorProperty.payload()] {
      case [Some(c), Some(e)]: Some(compose(c, e));
      case _: None;
    }
  }

  public function payload(): Option<Payload> return _payload;
}

class ComponentsAndPropertiesProcessor<ComponentsPayload, PropertyPayload, Payload, Component, Property> implements Processor<Payload, Component, Property> {
  var _payload = None;
  var processorComponents: Processor<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var processorProperty: Processor<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(phase: Phase<Component, Property>, matchEntity: Iterator<Component> -> Option<ComponentsPayload>, matchProperty: Iterator<Property> -> Option<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.processorComponents = new ComponentProcessor(matchEntity);
    this.processorProperty = new PropertiesProcessor(matchProperty);
    this.compose = compose;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    processorComponents.onChange(change);
    processorProperty.onChange(change);
    _payload = switch [processorComponents.payload(), processorProperty.payload()] {
      case [Some(c), Some(e)]: Some(compose(c, e));
      case _: None;
    }
  }

  public function payload(): Option<Payload> return _payload;
}

class PropertyProcessor<Payload, Component, Property> implements Processor<Payload, Component, Property> {
  var _payload = None;
  var matchProperty: Property -> Option<Payload>;
  public function new(matchProperty: Property -> Option<Payload>) {
    this.matchProperty = matchProperty;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case PropertyAdded(e):
        switch matchProperty(e) {
          case v = Some(_): _payload = v;
          case None:
        }
      case PropertyRemoved(e):
        _payload = None;
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  public function payload(): Option<Payload> return _payload;
}

class PropertiesProcessor<Payload, Component, Property> implements Processor<Payload, Component, Property> {
  var matchProperties: Iterator<Property> -> Option<Payload>;
  var properties: Array<Property>;
  var _payload = None;
  public function new(matchProperties: Iterator<Property> -> Option<Payload>) {
    this.matchProperties = matchProperties;
    properties = [];
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case PropertyAdded(e):
        properties.push(e);
        switch matchProperties(properties.iterator()) {
          case v = Some(_): _payload = v;
          case None:
        }
      case PropertyRemoved(e):
        properties.remove(e);
        switch matchProperties(properties.iterator()) {
          case v = Some(_): _payload = v;
          case None:
        }
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  public function payload(): Option<Payload> return _payload;
}

class ComponentProcessor<Payload, Component, Property> implements Processor<ReadonlyArray<ItemEntity<Payload, Component>>, Component, Property> {
  var map: OrderedMap<Entity<Component>, ItemEntity<Payload, Component>>;
  var matchEntity: Iterator<Component> -> Option<Payload>;
  var _payload = None;
  public function new(matchEntity: Iterator<Component> -> Option<Payload>) {
    map = OrderedMap.createObject();
    this.matchEntity = matchEntity;
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case EntityCreated(e):
        switch matchEntity(e.components()) {
          case Some(p):
            map.set(e, { data: p, entity: e });
          case None: // do nothing
        }
      case EntityUpdated(e):
        switch matchEntity(e.components()) {
          case Some(p):
            map.set(e, { data: p, entity: e });
          case None:
            map.remove(e);
        }
      case EntityRemoved(e):
        map.remove(e);
      case PropertyAdded(e): // do nothing
      case PropertyRemoved(e): // do nothing
    }
    _payload = switch _payload {
      case None if(map.length == 0): None;
      case _: Some(map.toArray()); // todo inefficient
    };
  }

  public function payload(): Option<ReadonlyArray<ItemEntity<Payload, Component>>> return _payload;
}

typedef ItemEntity<ItemPayload, Component> = {
  data: ItemPayload,
  entity: Entity<Component>
}
