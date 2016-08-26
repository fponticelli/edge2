using thx.Floats;

class Point {
  public var x: Float;
  public var y: Float;
  public function new(x: Float, y: Float) {
    this.x = x;
    this.y = y;
  }

  public function steerToward(from: Point, to: Point, maxSteer: Float) {
    var vb = new Point(to.x - from.x, to.y - from.y),
        d = normalizeDirection(vb.angle() - angle());
    rotate(d.abs().min(maxSteer) * d.sign());
  }

  public function angle()
    return Math.atan2(y, x);

  public function length()
    return Math.sqrt(x * x + y * y);

  public function rotate(rot) {
    var l = length(),
        a = angle() + rot;
    x = Math.cos(a) * l;
    y = Math.sin(a) * l;
    return this;
  }

  static var turn = 2 * Math.PI;
  public static function normalizeDirection(v: Float): Float {
    v = v % turn;
    if(v > Math.PI)
      v -= turn;
    else if(v < -Math.PI)
      v += turn;
    return v;
  }
}
