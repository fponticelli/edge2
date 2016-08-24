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
  public function createPhase(): Phase<Component, Element> {
    return throw new thx.error.NotImplemented();
  }
  public function phases(): Iterable<Phase<Component, Element>> { // ?
    return throw new thx.error.NotImplemented();
  }

  // entities
  var _entities: Set<Entity<Component, Element>>;
  public function createEntity(components: Iterable<Component>): Entity<Component, Element> {
    var entity = new Entity(entityChanged);
    _entities.add(entity);
    return entity;
  }

  public function removeEntity(predicate: Entity<Component, Element> -> Bool): Void {
    for(entity in _entities) {
      if(predicate(entity)) {
        entity.destroy();
        return;
      }
    }
  }

  function entityDestroyed(entity: Entity<Component, Element>) {
    _entities.remove(entity);
    // TODO
  }

  function entityUpdated(entity: Entity<Component, Element>) {
    // TODO
  }

  function entityChanged(entity: Entity<Component, Element>, change: EntityChange) switch change {
    case Updated: entityUpdated(entity);
    case Destroyed: entityDestroyed(entity);
  }

  public function removeEntities(predicate: Entity<Component, Element> -> Bool): Void {
    for(entity in _entities) {
      if(predicate(entity)) {
        entity.destroy();
      }
    }
  }
  public function clearEntities(): Void {
    return removeEntities(function(_) return true);
  }

  public function entities(): Iterator<Entity<Component, Element>>
    return _entities.iterator();

  // Elements
  var _elements: Set<Element>;
  public function addElement(Element: Element): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeElement(predicate: Element -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function removeElements(predicate: Element -> Bool): Void {
    return throw new thx.error.NotImplemented();
  }
  public function clearElements(): Void {
    return throw new thx.error.NotImplemented();
  }

  public function elements(): Iterator<Element>
    return _elements.iterator();

  public function clear(): Void {
    return throw new thx.error.NotImplemented();
  }
}
