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
  public function new(phase: Phase<Component, Property>, matchEntity: ReadonlyArray<Component> -> Option<ComponentsPayload>, matchProperty: Property -> Option<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
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
  public function new(phase: Phase<Component, Property>, matchEntity: ReadonlyArray<Component> -> Option<ComponentsPayload>, matchProperty: ReadonlyArray<Property> -> Option<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
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
  var matchProperties: ReadonlyArray<Property> -> Option<Payload>;
  var properties: Array<Property>;
  var _payload = None;
  public function new(matchProperties: ReadonlyArray<Property> -> Option<Payload>) {
    this.matchProperties = matchProperties;
    properties = [];
  }

  public function onChange(change: StatusChange<Component, Property>): Void {
    switch change {
      case PropertyAdded(e):
        properties.push(e);
        switch matchProperties(properties) {
          case v = Some(_): _payload = v;
          case None:
        }
      case PropertyRemoved(e):
        properties.remove(e);
        switch matchProperties(properties) {
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
  var matchEntity: ReadonlyArray<Component> -> Option<Payload>;
  public function new(matchEntity: ReadonlyArray<Component> -> Option<Payload>) {
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
  }

  public function payload(): Option<ReadonlyArray<ItemEntity<Payload, Component>>>
    return if(map.length == 0) None else Some(map.toArray());
}

typedef ItemEntity<ItemPayload, Component> = {
  data: ItemPayload,
  entity: Entity<Component>
}
