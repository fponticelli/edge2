import edge.View;
import minicanvas.MiniCanvas;
import thx.Unit;
using thx.ReadonlyArray;

class RenderDots {
  var mini : MiniCanvas;
  public function new(mini : MiniCanvas)
    this.mini = mini;

  public function update(list: ReadonlyArray<ItemEntity<{ position: Point, color: thx.color.Hsl }, Components, Unit>>) {
    mini.clear();
    for(item in list)
      mini.dot(item.data.position.x, item.data.position.y, 2, item.data.color);
  }
}
