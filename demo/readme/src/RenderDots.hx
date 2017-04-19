import edge.Processor;
import minicanvas.MiniCanvas;
import thx.Unit;
using thx.ReadonlyArray;
import Components;
import thx.color.Hsl;
import thx.Maybe;

class RenderDots {
  var mini : MiniCanvas;
  public function new(mini : MiniCanvas)
    this.mini = mini;

  public function update(list: ReadonlyArray<ItemEntity<{ position: Point, color: Hsl }, Components>>) {
    mini.clear();
    for(item in list)
      mini.dot(item.data.position.x, item.data.position.y, 2, item.data.color);
  }

  public static function extract(comps: ReadonlyArray<Components>) {
    var out = { position: Maybe.none(), color: Hsl.create(0, 0, 0) };
    for(comp in comps) switch comp {
      case Position(point): out.position = Maybe.of(point);
      case Color(color): out.color = color;
      case _:
    }
    return switch out {
      case { position: pos } if(pos.hasValue()): Maybe.of({ position: pos.get(), color: out.color });
      case _: Maybe.none();
    };
  }
}
