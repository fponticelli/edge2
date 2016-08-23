package edge;

abstract TimeSpan(Float) {
  inline public static function fromMillis(ms: Float)
    return new TimeSpan(ms);

  inline public static function fromSeconds(s: Float)
    return fromMillis(s * 1000);

  public var millis(get, never): Float;
  public var seconds(get, never): Float;

  inline function new(v: Float)
    this = v;

  inline function get_millis()
    return this;

  inline function get_seconds()
    return this / 1000.0;
}
