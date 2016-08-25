package edge;

import haxe.ds.Option;
import thx.OrderedMap;
import thx.ReadonlyArray;

class View<Payload, Component, Element> {
  public static function components<ItemPayload, Component>(extractor: Iterator<Component> -> Option<ItemPayload>)
    return new ComponentView(extractor);

  public function onChange(change: StatusChange<Component, Element>): Void {}
  public var payload(default, null): Option<Payload>;
}

class ComponentView<ItemPayload, Component, Element> extends View<ReadonlyArray<ItemEntity<ItemPayload, Component, Element>>, Component, Element> {
  var map: OrderedMap<Entity<Component, Element>, ItemEntity<ItemPayload, Component, Element>>;
  var matchEntity: Iterator<Component> -> Option<ItemPayload>;
  public function new(matchEntity: Iterator<Component> -> Option<ItemPayload>) {
    payload = None;
    map = OrderedMap.createObject();
    this.matchEntity = matchEntity;
  }

  override public function onChange(change: StatusChange<Component, Element>): Void {
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
      case ElementCreated(e): // do nothing
      case ElementRemoved(e): // do nothing
    }
    payload = switch payload {
      case None if(map.length == 0): None;
      case _: Some(map.toArray()); // todo inefficient
    };
  }
}

typedef ItemEntity<ItemPayload, Component, Element> = {
  data: ItemPayload,
  entity: Entity<Component, Element>
}
