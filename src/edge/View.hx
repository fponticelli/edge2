package edge;

import haxe.ds.Option;
import thx.OrderedMap;
import thx.ReadonlyArray;

class View<Payload, Component, Environment> {
  public static function components<ItemPayload, Component>(extractor: Iterator<Component> -> Option<ItemPayload>)
    return new ComponentView(extractor);
  public static function environment<ItemPayload, Environment>(extractor: Environment -> Option<ItemPayload>)
    return new EnvironmentView(extractor);

  public function onChange(change: StatusChange<Component, Environment>): Void {}
  public var payload(default, null): Option<Payload>;
}

class EnvironmentView<ItemPayload, Component, Environment> extends View<ItemPayload, Component, Environment> {
  var matchEnvironment: Environment -> Option<ItemPayload>;
  public function new(matchEnvironment: Environment -> Option<ItemPayload>) {
    payload = None;
    this.matchEnvironment = matchEnvironment;
  }

  override public function onChange(change: StatusChange<Component, Environment>): Void {
    switch change {
      case EnvironmentCreated(e):
        switch matchEnvironment(e) {
          case v = Some(_): payload = v;
          case None:
        }
      case EnvironmentRemoved(e):
        payload = None;
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }
}

class ComponentView<ItemPayload, Component, Environment> extends View<ReadonlyArray<ItemEntity<ItemPayload, Component, Environment>>, Component, Environment> {
  var map: OrderedMap<Entity<Component, Environment>, ItemEntity<ItemPayload, Component, Environment>>;
  var matchEntity: Iterator<Component> -> Option<ItemPayload>;
  public function new(matchEntity: Iterator<Component> -> Option<ItemPayload>) {
    payload = None;
    map = OrderedMap.createObject();
    this.matchEntity = matchEntity;
  }

  override public function onChange(change: StatusChange<Component, Environment>): Void {
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
      case EnvironmentCreated(e): // do nothing
      case EnvironmentRemoved(e): // do nothing
    }
    payload = switch payload {
      case None if(map.length == 0): None;
      case _: Some(map.toArray()); // todo inefficient
    };
  }
}

typedef ItemEntity<ItemPayload, Component, Environment> = {
  data: ItemPayload,
  entity: Entity<Component, Environment>
}
