// Every property automatically has a {Name}Changed signal.
// Custom signals are declared with signal.
// Functions are declared with function and can be called externally via id.functionName().
Item {
  id: panel
  property bool open: false

  // Built-in signal handler — fires when 'open' changes
  onOpenChanged: console.log("open is now:", open)

  // Custom signal
  signal toggled(bool newState)

  // Function — callable from outside as panel.toggle()
  function toggle() {
    open = !open
    toggled(open)         // emit the signal
  }

  // Special attached signals
  Component.onCompleted: console.log("constructed")
  Component.onDestruction: console.log("torn down")
}
