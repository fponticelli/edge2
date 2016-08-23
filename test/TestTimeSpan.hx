import edge.TimeSpan;

import utest.Assert;

class TestTimeSpan {
  public function new() {}

  public function testConversions() {
    var s = TimeSpan.fromMillis(20);
    Assert.equals(20, s.millis);
    Assert.equals(0.02, s.seconds);
  }
}
