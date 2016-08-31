package edge;

using thx.Arrays;
using thx.ReadonlyArray;

abstract TimeSpan(Float) {
  inline public static function fromMillis(ms: Float)
    return new TimeSpan(ms);

  inline public static function fromSeconds(s: Float)
    return fromMillis(s * 1000);

  public var millis(get, never): Float;
  public var seconds(get, never): Float;

  inline function new(v: Float)
    this = v;

  inline public function toFramesPerSecond()
    return 1.0 / seconds;

  inline function get_millis()
    return this;

  inline function get_seconds()
    return this / 1000.0;

  inline public function perSecond(value: Float): Float
    return value * millis / 1000;

  public static function average(arr: ReadonlyArray<TimeSpan>)
    return TimeSpan.fromMillis(sum(arr).millis / arr.length);

  public static function sum(arr : ReadonlyArray<TimeSpan>) : Null<TimeSpan>
    return TimeSpan.fromMillis(Arrays.reduce(arr, function(tot, v) return tot + v.millis, 0.0));
}
