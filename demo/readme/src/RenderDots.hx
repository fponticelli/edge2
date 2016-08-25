import edge.View;
import minicanvas.MiniCanvas;
import thx.Unit;
using thx.ReadonlyArray;

class RenderDots {
  var mini : MiniCanvas;
  public function new(mini : MiniCanvas)
    this.mini = mini;

  public function update(list: ReadonlyArray<ItemEntity<Point, Components, Unit>>) {
    mini.clear();
    for(item in list)
      mini.dot(item.data.x, item.data.y, 2, 0x000000FF);
  }
}
