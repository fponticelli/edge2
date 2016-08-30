package edge;

import haxe.ds.Option;
import thx.OrderedMap;
import thx.ReadonlyArray;

class View<Payload, Component, Environment> {
  public static function components<ItemPayload, Component>(extractor: Iterator<Component> -> Option<ItemPayload>)
    return new ComponentView(extractor);
  public static function environment<ItemPayload, Environment>(extractor: Environment -> Option<ItemPayload>)
    return new EnvironmentView(extractor);
  public static function environments<ItemPayload, Environment>(extractor: Iterator<Environment> -> Option<ItemPayload>)
    return new EnvironmentsView(extractor);

  public function onChange(change: StatusChange<Component, Environment>): Void {}
  public function payload(): Option<Payload> return None;
}

class EnvironmentView<Payload, Component, Environment> extends View<Payload, Component, Environment> {
  var _payload = None;
  var matchEnvironment: Environment -> Option<Payload>;
  public function new(matchEnvironment: Environment -> Option<Payload>) {
    _payload = None;
    this.matchEnvironment = matchEnvironment;
  }

  override public function onChange(change: StatusChange<Component, Environment>): Void {
    switch change {
      case EnvironmentCreated(e):
        switch matchEnvironment(e) {
          case v = Some(_): _payload = v;
          case None:
        }
      case EnvironmentRemoved(e):
        _payload = None;
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  override function payload(): Option<Payload> return _payload;
}

class EnvironmentsView<Payload, Component, Environment> extends View<Payload, Component, Environment> {
  var matchEnvironments: Iterator<Environment> -> Option<Payload>;
  var environments: Array<Environment>;
  var _payload = None;
  public function new(matchEnvironments: Iterator<Environment> -> Option<Payload>) {
    _payload = None;
    this.matchEnvironments = matchEnvironments;
    environments = [];
  }

  override public function onChange(change: StatusChange<Component, Environment>): Void {
    switch change {
      case EnvironmentCreated(e):
        environments.push(e);
        switch matchEnvironments(environments.iterator()) {
          case v = Some(_): _payload = v;
          case None:
        }
      case EnvironmentRemoved(e):
        environments.remove(e);
        switch matchEnvironments(environments.iterator()) {
          case v = Some(_): _payload = v;
          case None:
        }
      case EntityCreated(_), EntityUpdated(_), EntityRemoved(_):
        // do nothing
    }
  }

  override function payload(): Option<Payload> return _payload;
}

class ComponentView<Payload, Component, Environment> extends View<ReadonlyArray<ItemEntity<Payload, Component, Environment>>, Component, Environment> {
  var map: OrderedMap<Entity<Component, Environment>, ItemEntity<Payload, Component, Environment>>;
  var matchEntity: Iterator<Component> -> Option<Payload>;
  var _payload = None;
  public function new(matchEntity: Iterator<Component> -> Option<Payload>) {
    _payload = None;
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
    _payload = switch _payload {
      case None if(map.length == 0): None;
      case _: Some(map.toArray()); // todo inefficient
    };
  }

  override function payload(): Option<ReadonlyArray<ItemEntity<Payload, Component, Environment>>> return _payload;
}

typedef ItemEntity<ItemPayload, Component, Environment> = {
  data: ItemPayload,
  entity: Entity<Component, Environment>
}
