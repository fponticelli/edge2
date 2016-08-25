import edge.*;
import edge.View;
import thx.Unit;
using thx.ReadonlyArray;
import thx.color.Hsl;
import Components;
import haxe.ds.Option;

class Game {
  public static var width(default, null) = 400;
  public static var height(default, null) = 400;

  public static function main() {
    var mini = MiniCanvas.create(width, height).display("basic example"),
        engine = Engine.withEnumElement(),
        phase = engine.createPhase();

    phase.addView(View.components(function(comps) {
      var out = { position: None, velocity: None };
      for(comp in comps) switch comp {
        case Position(point): out.position = Some(point);
        case Velocity(point): out.velocity = Some(point);
        case _:
      }
      return switch out {
        case { position: Some(pos), velocity: Some(vel) }: Some({ position: pos, velocity: vel });
        case _: None;
      };
    }))
      .with(Move.system);

    phase.addView(View.components(function(comps) {
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
    }))
      .with(new RenderDots(mini).update);

    for(i in 0...300)
      engine.createEntity([
        Position(new Point(size(width), size(height))),
        Velocity(new Point(center(5), center(5))),
        Color(thx.color.Hsl.create(Math.random() * 360, 0.8, 0.8))
      ]);
    for(i in 0...30)
      engine.createEntity([
        Position(new Point(size(width), size(height))),
      ]);

    createLoop(phase.update);
  }

  static function size(s: Float)
    return s * Math.random();

  static function center(s: Float)
    return (s * Math.random()) - s / 2.0;

  static function createLoop(update: Void -> Void) {
    function loop() {
      update();
      thx.Timer.nextFrame(loop);
    }
    loop();
  }
}
