class TestAll {
  public static function main() {
    utest.UTest.run([
      new TestComponents(),
      new TestEntity(),
      new TestTimeSpan(),
    ]);
  }
}
