class TestAll {
  public static function main() {
    utest.UTest.run([
      new TestComponents(),
      new TestElement(),
      new TestEntity(),
      new TestTimeSpan(),
    ]);
  }
}
