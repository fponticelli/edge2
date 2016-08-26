package edge;

import thx.Set;
import edge.Entity;

class Engine<Component, Environment> {
  public static function withEnumEnvironment<Component, Environment : EnumValue>(): Engine<Component, Environment>
    return new Engine(function(): Set<Environment> return cast Set.createEnum());

  public function new(createEnvironmentSet : Void -> Set<Environment>) {
    _entities = Set.createObject();
    _environments = createEnvironmentSet();
  }

  // phases
  var _phases: Array<Phase<Component, Environment>> = [];
  public function createPhase(): Phase<Component, Environment> {
    // TODO
    var phase = new Phase();
    _phases.push(phase);
    return phase;
  }
  public function phases(): Iterator<Phase<Component, Environment>>
    return _phases.iterator();

  // entities
  var _entities: Set<Entity<Component, Environment>>;
  public function createEntity(components: Array<Component>): Entity<Component, Environment> {
    var entity = new Entity(this, components, statusChange);
    // TODO
    _entities.add(entity);
    statusChange(EntityCreated(entity));
    return entity;
  }

  public function removeEntity(predicate: Entity<Component, Environment> -> Bool): Bool {
    for(entity in _entities) {
      if(predicate(entity)) {
        entity.destroy();
        return true;
      }
    }
    return false;
  }

  function entityDestroyed(entity: Entity<Component, Environment>) {
    _entities.remove(entity);
    // TODO
  }

  function entityUpdated(entity: Entity<Component, Environment>) {
    // TODO
  }

  function statusChange(change: StatusChange<Component, Environment>) {
    switch change {
      case EntityUpdated(e): entityUpdated(e);
      case EntityCreated(e): entityUpdated(e);
      case EntityRemoved(e): entityDestroyed(e);
      case _: // TODO
      // case EnvironmentCreated(e): environmentCreated(e);
      // case EnvironmentRemoved(e): environmentRemoved(e);
    }
    for(phase in _phases) {
      phase.propagate(change);
    }
  }

  public function removeEntities(predicate: Entity<Component, Environment> -> Bool): Bool {
    var removed = false;
    for(entity in _entities) {
      if(predicate(entity)) {
        entity.destroy();
        removed = true;
      }
    }
    return removed;
  }

  public function clearEntities(): Engine<Component, Environment> {
    removeEntities(function(_) return true);
    return this;
  }

  public function entities(): Iterator<Entity<Component, Environment>>
    return _entities.iterator();

  // Environments
  var _environments: Set<Environment>;
  public function addEnvironment(environment: Environment): Void {
    // TODO
    _environments.add(environment);
  }

  function environmentRemoved(environment: Environment) {
    _environments.remove(environment);
    // TODO
  }

  public function removeEnvironment(predicate: Environment -> Bool): Bool {
    for(environment in _environments) {
      if(predicate(environment)) {
        environmentRemoved(environment);
        return true;
      }
    }
    return false;
  }
  public function removeEnvironments(predicate: Environment -> Bool): Bool {
    var removed = false;
    for(environment in _environments) {
      if(predicate(environment)) {
        environmentRemoved(environment);
        removed = true;
      }
    }
    return removed;
  }
  public function clearEnvironments(): Engine<Component, Environment> {
    removeEnvironments(function(_) return true);
    return this;
  }

  public function environments(): Iterator<Environment>
    return _environments.iterator();

  public function clear(): Void {
    clearEntities();
    clearEnvironments();
  }
}
