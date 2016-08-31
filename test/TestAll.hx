class TestAll {
  public static function main() {
    utest.UTest.run([
      new TestComponents(),
      new TestEngine(),
      new TestEntity(),
      new TestPhase(),
      new TestProcessor(),
      new TestProperty(),
      new TestTimeSpan(),
    ]);
  }
}
