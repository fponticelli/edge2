package system;

import edge.ItemEntity;
import minicanvas.MiniCanvas;
using thx.ReadonlyArray;
import Component;
import thx.color.Hsl;

class RenderDots {
  public static function system(x: { property: MiniCanvas, items: ReadonlyArray<ItemEntity<{ position: Point, color: Hsl }, Component>> }) {
    var mini = x.property;
    for(item in x.items)
      mini.dot(item.data.position.x, item.data.position.y, 2, item.data.color);
  }
}
