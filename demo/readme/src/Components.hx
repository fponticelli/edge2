import thx.color.Hsl;

enum Components {
  Position(coords: Point);
  Velocity(vector: Point);
  Color(hsl: Hsl);
}
