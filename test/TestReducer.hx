import AComponent;
import AProperty;
import utest.Assert;
import edge.Engine;
import edge.Entity;
import edge.Phase;
import edge.StatusChange;
import thx.Maybe;
import thx.ReadonlyArray;

class TestReducer {
  var events: Array<StatusChange<AComponent, AProperty>>;
  public function new() {
    var e = new Entity([CA], function(_) {});
    events = [
      PropertyAdded(EA),
      PropertyRemoved(EA),
      EntityCreated(e),
      EntityUpdated(e),
      EntityRemoved(e)
    ];
  }

  public function testBasics() {
    var p = new Phase(null),
        comps = [],
        envs = [];
    p.reduceComponentsProperties(
      function(e: ReadonlyArray<AComponent>) {
        comps.push(e.copy());
        return Maybe.of("comp");
      },
      function(e: ReadonlyArray<AProperty>) {
        envs.push(e.copy());
        return Maybe.of("env");
      }
    );
    for(e in events)
      p.dispatch(e);
    Assert.same([[CA], [CA]], comps);
    Assert.same([[EA], []], envs);
  }

  public function testIssue20170419() {
    var engine = new Engine();
    var phase = engine.phases.create();

    engine.properties.add(EA);
    engine.properties.add(EB);

    var acc = [];

    phase
      .reduceComponentsProperty(
        function(arr: ReadonlyArray<AComponent>) {
          for(c in arr)
            if(c == CB) return Maybe.of("CB");
          return Maybe.none();
        },
        function(p: AProperty) {
          return switch p {
            case EA: Maybe.of("EA");
            case _: Maybe.none();
          }
        })
      .feed(function(x) {
        acc.push(x.property);
        acc = acc.concat(x.items.map(function(e) return e.data));
      });

    phase
      .reduceProperty(function(p: AProperty) {
        return switch p {
          case EA: Maybe.of("EA");
          case _: Maybe.none();
        }
      })
      .feed(function(p) {
        acc.push(p);
      });

    engine.entities.create([CA, CB]);
    engine.entities.create([CB, CC]);

    phase.update();
    Assert.same(["EA", "CB", "CB", "EA"], acc);
  }
}
