package edge;

import haxe.ds.Option;
import thx.OrderedMap;
import thx.ReadonlyArray;

class View<Payload, Component, Property> {
  public static function components<Payload, Component, Property>(extractor: Iterator<Component> -> Option<Payload>): View<ReadonlyArray<ItemEntity<Payload, Component>>, Component, Property>
    return new ComponentView(extractor);
  public static function property<Payload, Component, Property>(extractor: Property -> Option<Payload>): View<Payload, Component, Property>
    return new PropertyView(extractor);
  public static function properties<Payload, Component, Property>(extractor: Iterator<Property> -> Option<Payload>): View<Payload, Component, Property>
    return new PropertiesView(extractor);
  public static function componentsProperty<ComponentsPayload, PropertyPayload, Payload, Component, Property>(
    extractorEntity: Iterator<Component> -> Option<ComponentsPayload>,
    extractorProperty: Property -> Option<PropertyPayload>
  ): View<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }, Component, Property>
    return new ComponentsAndPropertyView(extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    });
  public static function componentsProperties<ComponentsPayload, PropertyPayload, Payload, Component, Property>(
    extractorEntity: Iterator<Component> -> Option<ComponentsPayload>,
    extractorProperty: Iterator<Property> -> Option<PropertyPayload>
  ): View<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component>>,
    property: PropertyPayload
  }, Component, Property>
    return new ComponentsAndPropertiesView(extractorEntity, extractorProperty, function(c, e) return {
      items: c,
      property: e
    });

  public function onChange(change: StatusChange<Component, Property>): Void {}
  public function payload(): Option<Payload> return None;
}

class ComponentsAndPropertyView<ComponentsPayload, PropertyPayload, Payload, Component, Property> extends View<Payload, Component, Property> {
  var _payload = None;
  var viewComponents: View<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var viewProperty: View<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(matchEntity: Iterator<Component> -> Option<ComponentsPayload>, matchProperty: Property -> Option<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.viewComponents = View.components(matchEntity);
    this.viewProperty = View.property(matchProperty);
    this.compose = compose;
  }

  override public function onChange(change: StatusChange<Component, Property>): Void {
    viewComponents.onChange(change);
    viewProperty.onChange(change);
    _payload = switch [viewComponents.payload(), viewProperty.payload()] {
      case [Some(c), Some(e)]: Some(compose(c, e));
      case _: None;
    }
  }

  override function payload(): Option<Payload> return _payload;
}

class ComponentsAndPropertiesView<ComponentsPayload, PropertyPayload, Payload, Component, Property> extends View<Payload, Component, Property> {
  var _payload = None;
  var viewComponents: View<ReadonlyArray<ItemEntity<ComponentsPayload, Component>>, Component, Property>;
  var viewProperty: View<PropertyPayload, Component, Property>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload;
  public function new(matchEntity: Iterator<Component> -> Option<ComponentsPayload>, matchProperty: Iterator<Property> -> Option<PropertyPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component>> -> PropertyPayload -> Payload) {
    this.viewComponents = View.components(matchEntity);
    this.viewProperty = View.properties(matchProperty);
    this.compose = compose;
  }

  override public function onChange(change: StatusChange<Component, Property>): Void {
    viewComponents.onChange(change);
    viewProperty.onChange(change);
    _payload = switch [viewComponents.payload(), viewProperty.payload()] {
      case [Some(c), Some(e)]: Some(compose(c, e));
      case _: None;
    }
  }

  override function payload(): Option<Payload> return _payload;
}

class PropertyView<Payload, Component, Property> extends View<Payload, Component, Property> {
  var _payload = None;
  var matchProperty: Property -> Option<Payload>;
  public function new(matchProperty: Property -> Option<Payload>) {
    this.matchProperty = matchProperty;
  }

  override public function onChange(change: StatusChange<Component, Property>): Void {
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

  override function payload(): Option<Payload> return _payload;
}

class PropertiesView<Payload, Component, Property> extends View<Payload, Component, Property> {
  var matchProperties: Iterator<Property> -> Option<Payload>;
  var properties: Array<Property>;
  var _payload = None;
  public function new(matchProperties: Iterator<Property> -> Option<Payload>) {
    this.matchProperties = matchProperties;
    properties = [];
  }

  override public function onChange(change: StatusChange<Component, Property>): Void {
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

  override function payload(): Option<Payload> return _payload;
}

class ComponentView<Payload, Component, Property> extends View<ReadonlyArray<ItemEntity<Payload, Component>>, Component, Property> {
  var map: OrderedMap<Entity<Component>, ItemEntity<Payload, Component>>;
  var matchEntity: Iterator<Component> -> Option<Payload>;
  var _payload = None;
  public function new(matchEntity: Iterator<Component> -> Option<Payload>) {
    map = OrderedMap.createObject();
    this.matchEntity = matchEntity;
  }

  override public function onChange(change: StatusChange<Component, Property>): Void {
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

  override function payload(): Option<ReadonlyArray<ItemEntity<Payload, Component>>> return _payload;
}

typedef ItemEntity<ItemPayload, Component> = {
  data: ItemPayload,
  entity: Entity<Component>
}
