package edge;

class Entity<Component, Environment> {
  public var destroyed(default, null): Bool;
  public var engine(default, null): Engine<Component, Environment>;

  var list: Array<Component>;
  var change: StatusChange<Component, Environment> -> Void;

  public function new(engine: Engine<Component, Environment>, components: Array<Component>, change: StatusChange<Component, Environment> -> Void) {
    this.engine = engine;
    this.destroyed = false;
    this.list = components;
    this.change = change;
  }

  public function addComponent(c: Component) {
    list.push(c);
    change(EntityUpdated(this));
    return this;
  }

  public function addComponents(cs: Array<Component>) {
    if(cs.length == 0) return this;
    list = list.concat(cs);
    change(EntityUpdated(this));
    return this;
  }

  public function update(handler: Array<Component> -> Array<Component>) {
    list = handler(list);
    change(EntityUpdated(this));
    return this;
  }

  public function removeComponents(predicate: Component -> Bool): Bool {
    var len = list.length;
    list = list.filter(function(v) return !predicate(v));
    if(list.length == len)
      return false;
    change(EntityUpdated(this));
    return true;
  }
  public function removeComponent(predicate: Component -> Bool): Bool {
    var item;
    for(i in 0...list.length) {
      item = list[i];
      if(predicate(item)) {
        list.splice(i, 1);
        change(EntityUpdated(this));
        return true;
      }
    }
    return false;
  }
  public function destroy(): Void {
    if(destroyed) return;
    destroyed = true;
    change(EntityRemoved(this));
  }

  public function components(): Iterator<Component>
    return list.iterator();
}
