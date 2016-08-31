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
    var phase = new Phase(this);
    _phases.push(phase);
    return phase;
  }
  public function phases(): Iterator<Phase<Component, Environment>>
    return _phases.iterator();

  // entities
  var _entities: Set<Entity<Component, Environment>>;
  public function createEntity(components: Array<Component>): Entity<Component, Environment> {
    var entity = new Entity(components, statusChange);
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

  function statusChange(change: StatusChange<Component, Environment>) {
    switch change {
      case EntityRemoved(e):
        _entities.remove(e);
      case _:
        // do nothing
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
    _environments.add(environment);
    statusChange(EnvironmentAdded(environment));
  }

  function _removeEnvironment(environment) {
    _environments.remove(environment);
    statusChange(EnvironmentRemoved(environment));
  }

  public function removeEnvironment(predicate: Environment -> Bool): Bool {
    for(environment in _environments) {
      if(predicate(environment)) {
        _removeEnvironment(environment);
        return true;
      }
    }
    return false;
  }
  public function removeEnvironments(predicate: Environment -> Bool): Bool {
    var removed = false;
    for(environment in _environments) {
      if(predicate(environment)) {
        _removeEnvironment(environment);
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
