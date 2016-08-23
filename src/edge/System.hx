package edge;

interface System<Component, Message> {
  var engine: Engine<Component, Message>;
  function before(timeDelta: TimeSpan): Void;
}
