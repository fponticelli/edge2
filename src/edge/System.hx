package edge;

interface System<Payload, Component, Element> {
  var engine: Engine<Component, Element>;
  function update(pl: Payload): Void;
}
