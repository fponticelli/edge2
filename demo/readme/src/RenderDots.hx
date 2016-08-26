import edge.View;
import minicanvas.MiniCanvas;
import thx.Unit;
using thx.ReadonlyArray;
import haxe.ds.Option;
import Components;
import thx.color.Hsl;

class RenderDots {
  var mini : MiniCanvas;
  public function new(mini : MiniCanvas)
    this.mini = mini;

  public function update(list: ReadonlyArray<ItemEntity<{ position: Point, color: Hsl }, Components, Unit>>) {
    mini.clear();
    for(item in list)
      mini.dot(item.data.position.x, item.data.position.y, 2, item.data.color);
  }

  public static function extract(comps: Iterator<Components>) {
    var out = { position: None, color: Hsl.create(0, 0, 0) };
    for(comp in comps) switch comp {
      case Position(point): out.position = Some(point);
      case Color(color): out.color = color;
      case _:
    }
    return switch out {
      case { position: Some(pos) }: Some({ position: pos, color: out.color });
      case _: None;
    };
  }
}
