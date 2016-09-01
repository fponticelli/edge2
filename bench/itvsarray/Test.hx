import thx.benchmark.speed.Suite;
using thx.Ints;
using thx.ReadonlyArray;

class Test {
  public static function main() {
    var s = new Suite();
    var values = Ints.range(1, 101);
    s.add("iterator", function() {
      var sum: Int = 0;
      @:measure {
        for(v in values.iterator())
          sum += v;
      }
      if(sum == 0)
        throw 'nothing happened';
    });
    s.add("array", function() {
      var sum: Int = 0;
      @:measure {
        for(v in values)
          sum += v;
      }
      if(sum == 0)
        throw 'nothing happened';
    });
    s.add("readonly array", function() {
      var sum: Int = 0;
      @:measure {
        var len = values.length;
        for(v in (values : ReadonlyArray<Int>))
          sum += v;
      }
      if(sum == 0)
        throw 'nothing happened';
    });
    var r = s.run();
    trace(r.toString());
  }
}
