// Ternary - conditional values
color: isActive ? "#7aa2f7" : "#444b6a"

// Optional chaining (?.) - safe property access on possibly-null objects
text: Hyprland.focusedWorkspace?.name ?? "none"

// Nullish coalescing (??) - fallback when value is null/undefined
percentage: UPower.displayDevice?.percentage ?? 0

// Array methods - find, filter, map all work
property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)

// Multi-line expressions need parens or a function
text: {
  if (count === 0) return "empty"
  if (count === 1) return "one item"
  return count + " items"
}

// Bindings re-evaluate when their dependencies change. If you use Date.now() or Math.random() in a binding, it only runs once at creation, they aren't reactive. Use a Timer or SystemClock for time-based reactivity.
