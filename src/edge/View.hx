package edge;

import haxe.ds.Option;
import thx.OrderedMap;
import thx.ReadonlyArray;

class View<Payload, Component, Environment> {
  public static function components<Payload, Component, Environment>(extractor: Iterator<Component> -> Option<Payload>): View<ReadonlyArray<ItemEntity<Payload, Component, Environment>>, Component, Environment>
    return new ComponentView(extractor);
  public static function environment<Payload, Component, Environment>(extractor: Environment -> Option<Payload>): View<Payload, Component, Environment>
    return new EnvironmentView(extractor);
  public static function environments<Payload, Component, Environment>(extractor: Iterator<Environment> -> Option<Payload>): View<Payload, Component, Environment>
    return new EnvironmentsView(extractor);
  public static function componentsEnvironment<ComponentsPayload, EnvironmentPayload, Payload, Component, Environment>(
    extractorEntity: Iterator<Component> -> Option<ComponentsPayload>,
    extractorEnvironment: Environment -> Option<EnvironmentPayload>
  ): View<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>>,
    environment: EnvironmentPayload
  }, Component, Environment>
    return new ComponentsAndEnvironmentView(extractorEntity, extractorEnvironment, function(c, e) return {
      items: c,
      environment: e
    });
  public static function componentsEnvironments<ComponentsPayload, EnvironmentPayload, Payload, Component, Environment>(
    extractorEntity: Iterator<Component> -> Option<ComponentsPayload>,
    extractorEnvironment: Iterator<Environment> -> Option<EnvironmentPayload>
  ): View<{
    items: ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>>,
    environment: EnvironmentPayload
  }, Component, Environment>
    return new ComponentsAndEnvironmentsView(extractorEntity, extractorEnvironment, function(c, e) return {
      items: c,
      environment: e
    });

  public function onChange(change: StatusChange<Component, Environment>): Void {}
  public function payload(): Option<Payload> return None;
}

class ComponentsAndEnvironmentView<ComponentsPayload, EnvironmentPayload, Payload, Component, Environment> extends View<Payload, Component, Environment> {
  var _payload = None;
  var viewComponents: View<ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>>, Component, Environment>;
  var viewEnvironment: View<EnvironmentPayload, Component, Environment>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>> -> EnvironmentPayload -> Payload;
  public function new(matchEntity: Iterator<Component> -> Option<ComponentsPayload>, matchEnvironment: Environment -> Option<EnvironmentPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>> -> EnvironmentPayload -> Payload) {
    this.viewComponents = View.components(matchEntity);
    this.viewEnvironment = View.environment(matchEnvironment);
    this.compose = compose;
  }

  override public function onChange(change: StatusChange<Component, Environment>): Void {
    viewComponents.onChange(change);
    viewEnvironment.onChange(change);
    _payload = switch [viewComponents.payload(), viewEnvironment.payload()] {
      case [Some(c), Some(e)]: Some(compose(c, e));
      case _: None;
    }
  }

  override function payload(): Option<Payload> return _payload;
}

class ComponentsAndEnvironmentsView<ComponentsPayload, EnvironmentPayload, Payload, Component, Environment> extends View<Payload, Component, Environment> {
  var _payload = None;
  var viewComponents: View<ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>>, Component, Environment>;
  var viewEnvironment: View<EnvironmentPayload, Component, Environment>;
  var compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>> -> EnvironmentPayload -> Payload;
  public function new(matchEntity: Iterator<Component> -> Option<ComponentsPayload>, matchEnvironment: Iterator<Environment> -> Option<EnvironmentPayload>, compose: ReadonlyArray<ItemEntity<ComponentsPayload, Component, Environment>> -> EnvironmentPayload -> Payload) {
    this.viewComponents = View.components(matchEntity);
    this.viewEnvironment = View.environments(matchEnvironment);
    this.compose = compose;
  }

  override public function onChange(change: StatusChange<Component, Environment>): Void {
    viewComponents.onChange(change);
    viewEnvironment.onChange(change);
    _payload = switch [viewComponents.payload(), viewEnvironment.payload()] {
      case [Some(c), Some(e)]: Some(compose(c, e));
      case _: None;
    }
  }

  override function payload(): Option<Payload> return _payload;
}

class EnvironmentView<Payload, Component, Environment> extends View<Payload, Component, Environment> {
  var _payload = None;
  var matchEnvironment: Environment -> Option<Payload>;
  public function new(matchEnvironment: Environment -> Option<Payload>) {
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
