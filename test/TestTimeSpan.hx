import edge.TimeSpan;

import utest.Assert;

class TestTimeSpan {
  public function new() {}

  public function testConversions() {
    Assert.equals(20,   TimeSpan.fromMillis(20).millis);
    Assert.equals(0.02, TimeSpan.fromMillis(20).seconds);
    Assert.equals(2,    TimeSpan.fromSeconds(2).seconds);
    Assert.equals(2000, TimeSpan.fromSeconds(2).millis);
  }
}
