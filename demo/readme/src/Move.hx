import edge.*;
import edge.Processor;
import thx.Unit;
using thx.ReadonlyArray;
import thx.Maybe;

class Move {
  public static function system(list: ReadonlyArray<ItemEntity<{ position: Point, velocity: Point }, Components>>) {
    for(item in list) {
      var pos = item.data.position,
          vel = item.data.velocity,
          dx = pos.x + vel.x,
          dy = pos.y + vel.y;
      if(dx <= 0 && vel.x < 0 || dx >= Game.width && vel.x > 0)
        vel.x = -vel.x;
      else
        pos.x = dx;
      if(dy <= 0 && vel.y < 0 || dy >= Game.height && vel.y > 0)
        vel.y = -vel.y;
      else
        pos.y = dy;
    }
  }

  public static function extract(comps: ReadonlyArray<Components>) {
    var out = { position: Maybe.none(), velocity: Maybe.none() };
    for(comp in comps) switch comp {
      case Position(point): out.position = point;
      case Velocity(point): out.velocity = point;
      case _:
    }
    return switch out {
      case { position: pos, velocity: vel } if(pos.hasValue() && vel.hasValue()):
        Maybe.of({ position: pos.get(), velocity: vel.get() });
      case _:
        Maybe.none();
    };
  }
}
