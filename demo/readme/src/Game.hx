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
        phase = engine.phases.create();

    engine.properties.add(Canvas(mini));

    phase
      .reduceComponents(Extract.positionVelocity)
      .feed(Physics.system);

    phase
      .reduceComponentsProperty(Extract.positionColor, Extract.canvas)
      .feed(RenderDots.system);

    for(i in 0...300)
      engine.entities.create([
        Position(new Point(size(width), size(height))),
        Velocity(new Point(center(5), center(5))),
        Color(thx.color.Hsl.create(Math.random() * 360, 0.8, 0.8))
      ]);
    for(i in 0...30)
      engine.entities.create([
        Position(new Point(size(width), size(height))),
      ]);

    createLoop(phase.update);
  }

  static function size(s: Float) return s * Math.random();
  static function center(s: Float) return (s * Math.random()) - s / 2.0;

  static function createLoop(update: Void -> Void) {
    function loop() {
      update();
      thx.Timer.nextFrame(loop);
    }
    loop();
  }
}
