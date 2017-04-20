package system;

import minicanvas.MiniCanvas;
import thx.color.Hsl;

class RenderMouse {
  static var color = Hsl.create(0.0, 0.25, 0.75);
  public static function system(x: { canvas: MiniCanvas, coords: Point }) {
    x.canvas.circle(x.coords.x, x.coords.y, 10, 2, color);
  }
}
