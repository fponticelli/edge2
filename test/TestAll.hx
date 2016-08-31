class TestAll {
  public static function main() {
    utest.UTest.run([
      new TestComponents(),
      new TestEngine(),
      new TestProperty(),
      new TestEntity(),
      new TestTimeSpan(),
      new TestPhase(),
      new TestView(),
    ]);
  }
}
