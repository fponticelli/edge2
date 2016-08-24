package edge;

interface System<Component, Element> {
  var engine: Engine<Component, Element>;
  function before(timeDelta: TimeSpan): Void;
}
