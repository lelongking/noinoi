Wings.Editor =
  isActive: new ReactiveVar(false)
  register: (selector) ->
    $element = if typeof selector is 'string' then $(selector) else selector
    $element.on "blur keyup paste copy cut mouseup", ->
      $(document).trigger('wingsEditorChange')

    $element.on "focus", ->
      Wings.Editor.currentInstance = $element
      Wings.Editor.isActive.set(true)
    $element.on "blur", ->
      Wings.Editor.isActive.set(false)
      obj.isActive.set(false) for command, obj of Wings.Editor.commands when obj.isActive isnt undefined

  commands: {}

$(document).on "wingsEditorChange", ->
  for name, obj of Wings.Editor.commands
    obj.isActive.set document.queryCommandState(name) if obj.isActive