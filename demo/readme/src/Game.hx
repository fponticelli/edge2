import edge.*;
import edge.View;
import thx.Unit;
using thx.ReadonlyArray;
import Components;
import haxe.ds.Option;

class Game {
  public static var width(default, null) = 200;
  public static var height(default, null) = 200;

  public static function main() {
    var mini = MiniCanvas.create(width, height).display("basic example"),
        engine = Engine.withEnumElement(),
        phase = engine.createPhase();

    phase.addView(View.components(function(comps) {
      var out = { position: None, velocity: None };
      for(comp in comps) switch comp {
        case Position(point): out.position = Some(point);
        case Velocity(point): out.velocity = Some(point);
      }
      return switch out {
        case { position: Some(pos), velocity: Some(vel) }: Some({ position: pos, velocity: vel });
        case _: None;
      };
    }))
      .with(moveSystem);

    phase.addView(View.components(function(comps) {
      for(comp in comps) switch comp {
        case Position(point): return Some(point);
        case _:
      }
      return None;
    }))
      .with(new RenderDots(mini).update);

    phase.addView(View.components(function(comps) {
      return None;
    }))
      .with(moveSystem);

    for(i in 0...300)
      engine.createEntity([
        Position(new Point(size(width), size(height))),
        Velocity(new Point(center(2), center(2))),
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

  static function moveSystem(list: ReadonlyArray<ItemEntity<{ position: Point, velocity: Point }, Components, Unit>>) {
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

  static function createLoop(update: Void -> Void) {
    function loop() {
      update();
      thx.Timer.nextFrame(loop);
    }
    loop();
  }
}
