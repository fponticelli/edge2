package edge;

class Entity<Component, Element> {
  public var destroyed(default, null): Bool;
  var list: Array<Component>;
  var entityChange: Entity<Component, Element> -> EntityChange -> Void;

  public function new(entityChange: Entity<Component, Element> -> EntityChange -> Void) {
    destroyed = false;
    list = [];
    this.entityChange = entityChange;
  }

  public function addComponent(c: Component) {
    list.push(c);
    entityChange(this, Updated);
    return this;
  }

  public function addComponents(cs: Array<Component>) {
    if(cs.length == 0) return this;
    list = list.concat(cs);
    entityChange(this, Updated);
    return this;
  }

  public function update(handler: Array<Component> -> Array<Component>) {
    list = handler(list);
    entityChange(this, Updated);
    return this;
  }

  public function removeComponents(predicate: Component -> Bool): Bool {
    var len = list.length;
    list = list.filter(function(v) return !predicate(v));
    if(list.length == len)
      return false;
    entityChange(this, Updated);
    return true;
  }
  public function removeComponent(predicate: Component -> Bool): Bool {
    var item;
    for(i in 0...list.length) {
      item = list[i];
      if(predicate(item)) {
        list.splice(i, 1);
        entityChange(this, Updated);
        return true;
      }
    }
    return false;
  }
  public function destroy(): Void {
    if(destroyed) return;
    destroyed = true;
    entityChange(this, Destroyed);
  }

  public function components(): Iterator<Component>
    return list.iterator();

  // maybe?
  // public var engine: Engine<Component, Element>;
}

enum EntityChange {
  Updated;
  Destroyed;
}
