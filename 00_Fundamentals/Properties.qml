//Anatomy of an object
TypeName {
  id: myId                       // identifier for cross-references
  property int count: 0          // declare typed properties with defaults
  readonly property string name: "fixed"
  property var anything          // 'var' = JS-typed, holds anything

  width: 200                     // bind a built-in property
  height: width / 2              // expression — re-evaluates when width changes

  onCountChanged: console.log(count)   // signal handler — runs on change
  Component.onCompleted: count = 5     // attached signal — fires on construction
}

// Here are some property types
// int / real / bool -> Primitive -> Numeric and boolean values. real is a double-precision float.
// string -> Primitive -> Text. Supports Unicode natively.
// color -> Value -> Accepts "#1a1b26", "red", Qt.rgba(0.1,0.2,0.3,1.0).
// url -> Value -> For Image.source, FileView.path, etc. Use Qt.resolvedUrl() for relative paths.
// var -> any -> JavaScript value — array, object, anything. Slowest binding evaluation; use sparingly.
// list<Type> -> Collection -> Typed list. Used for list<string> command args, child object lists, etc.
// point / size / rect -> Value -> Geometry value types — Qt.point(x,y), Qt.size(w,h), Qt.rect(x,y,w,h).
// <CustomType> -> QML type -> Reference any registered type — property PwNode sink, property HyprlandWorkspace ws.

// 'required' forces the property to be set by the parent; mostly used in delegates
PanelWindow {
  required property var modelData    // Variants will provide this; QML errors if not

  // 'readonly' prevents external writes — useful for derived/exposed values
  readonly property int paddedWidth: implicitWidth + 16
}
