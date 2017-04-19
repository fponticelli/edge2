import thx.color.Hsl;

enum Component {
  Position(coords: Point);
  Velocity(vector: Point);
  Color(hsl: Hsl);
}
