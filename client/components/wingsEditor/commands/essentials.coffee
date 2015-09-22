Wings.Editor.commands.bold =
  icon: "icon-bold"
  description: "In đậm"
  canExecute: true
  isActive: new ReactiveVar(false)
  command: -> document.execCommand("bold")

Wings.Editor.commands.italic =
  icon: "icon-italic"
  description: "In nghiêng"
  isActive: new ReactiveVar(false)
  command: -> document.execCommand("italic")

Wings.Editor.commands.underline =
  icon: "icon-underline"
  description: "Gạch dưới"
  isActive: new ReactiveVar(false)
  command: -> document.execCommand("underline")