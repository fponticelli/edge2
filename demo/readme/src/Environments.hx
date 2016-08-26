import minicanvas.MiniCanvas;

enum Environments {
  Canvas(canvas: MiniCanvas);
  MouseCoords(coords: Point);
}
