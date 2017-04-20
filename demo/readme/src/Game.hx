import edge.*;
import thx.color.Hsl;
import Property;
import system.*;

class Game {
  public static var width(default, null) = 400;
  public static var height(default, null) = 400;

  public static function main() {
    var mini = MiniCanvas.create(width, height).display("basic example"),
        engine = new Engine(),
        phase = engine.phases.create(),
        coords = new Point(-100, -100);

    engine.properties.add(MouseCoords(coords)); // TODO, position matters! it really shouldn't
    engine.properties.add(Canvas(mini)); // WHY!??!?

    phase
      .reduceComponentsProperty(Extract.positionVelocity, Extract.mouseCoords)
      .feed(Physics.system);

    phase
      .reduceProperty(Extract.canvas)
      .feed(RenderClear.system);

    phase
      .reduceProperties(Extract.canvasMouseCoords)
      .feed(RenderMouse.system);

    phase
      .reduceComponentsProperty(Extract.positionColor, Extract.canvas)
      .feed(RenderDots.system);

    mini.onMove(function(e) {
      coords.x = e.x;
      coords.y = e.y;
    });

    // phase
    //   .reduceProperty(Extract.canvas)
    //   .feed(Interactive.system);

    for(i in 0...2000)
      engine.entities.create([
        Position(new Point(size(width), size(height))),
        Velocity(new Point(center(5), center(5))),
        Color(thx.color.Hsl.create(Math.random() * 120 + 120, 0.9, 0.4))
      ]);

    createLoop(phase.update);
  }

  static function size(s: Float) return s * Math.random();
  static function center(s: Float) return (2 * s * Math.random()) - s;

  static function createLoop(update: Void -> Void) {
    function loop() {
      update();
      thx.Timer.nextFrame(loop);
    }
    loop();
  }
}
