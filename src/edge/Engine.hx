package edge;

import thx.Set;
import edge.Entity;

class Engine<Component, Element> {
  public static function withEnumElement<Component, Element : EnumValue>(): Engine<Component, Element>
    return new Engine(function(): Set<Element> return cast Set.createEnum());

  public function new(createElementSet : Void -> Set<Element>) {
    _entities = Set.createObject();
    _elements = createElementSet();
  }

  // phases
  var _phases: Array<Phase<Component, Element>> = [];
  public function createPhase(): Phase<Component, Element> {
    // TODO
    var phase = new Phase();
    _phases.push(phase);
    return phase;
  }
  public function phases(): Iterator<Phase<Component, Element>>
    return _phases.iterator();

  // entities
  var _entities: Set<Entity<Component, Element>>;
  public function createEntity(components: Array<Component>): Entity<Component, Element> {
    var entity = new Entity(this, components, statusChange);
    // TODO
    _entities.add(entity);
    statusChange(EntityCreated(entity));
    return entity;
  }

  public function removeEntity(predicate: Entity<Component, Element> -> Bool): Bool {
    for(entity in _entities) {
      if(predicate(entity)) {
        entity.destroy();
        return true;
      }
    }
    return false;
  }

  function entityDestroyed(entity: Entity<Component, Element>) {
    _entities.remove(entity);
    // TODO
  }

  function entityUpdated(entity: Entity<Component, Element>) {
    // TODO
  }

  function statusChange(change: StatusChange<Component, Element>) {
    switch change {
      case EntityUpdated(e): entityUpdated(e);
      case EntityCreated(e): entityUpdated(e);
      case EntityRemoved(e): entityDestroyed(e);
      case _: // TODO
      // case ElementCreated(e): elementCreated(e);
      // case ElementRemoved(e): elementRemoved(e);
    }
    for(phase in _phases) {
      phase.propagate(change);
    }
  }

  public function removeEntities(predicate: Entity<Component, Element> -> Bool): Bool {
    var removed = false;
    for(entity in _entities) {
      if(predicate(entity)) {
        entity.destroy();
        removed = true;
      }
    }
    return removed;
  }

  public function clearEntities(): Engine<Component, Element> {
    removeEntities(function(_) return true);
    return this;
  }

  public function entities(): Iterator<Entity<Component, Element>>
    return _entities.iterator();

  // Elements
  var _elements: Set<Element>;
  public function addElement(element: Element): Void {
    // TODO
    _elements.add(element);
  }

  function elementRemoved(element: Element) {
    _elements.remove(element);
    // TODO
  }

  public function removeElement(predicate: Element -> Bool): Bool {
    for(element in _elements) {
      if(predicate(element)) {
        elementRemoved(element);
        return true;
      }
    }
    return false;
  }
  public function removeElements(predicate: Element -> Bool): Bool {
    var removed = false;
    for(element in _elements) {
      if(predicate(element)) {
        elementRemoved(element);
        removed = true;
      }
    }
    return removed;
  }
  public function clearElements(): Engine<Component, Element> {
    removeElements(function(_) return true);
    return this;
  }

  public function elements(): Iterator<Element>
    return _elements.iterator();

  public function clear(): Void {
    clearEntities();
    clearElements();
  }
}
