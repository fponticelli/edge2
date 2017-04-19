import thx.color.Hsl;
import thx.Maybe;
import thx.ReadonlyArray;
import minicanvas.MiniCanvas;
import Component;

class Extract {
  public static function canvas(p: Property): Maybe<MiniCanvas> {
    return switch p {
      case Canvas(mini): mini;
      case _: null;
    };
  }

  public static function positionVelocity(comps: ReadonlyArray<Component>) {
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

  public static function positionColor(comps: ReadonlyArray<Component>) {
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
