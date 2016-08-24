package edge;

interface ElementView<T, Component, Element> {
  function onAddedElement(Element: Element): Void;
  function onRemovedElement(Element: Element): Void;

  function updateElementSystem(system: ElementSystem<T, Component, Element>): Void;
}
