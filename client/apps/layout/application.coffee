Wings.defineWidget "ApplicationLayout",
  rendered: ->
    Session.set("applicationStatus", "Trạng thái ổn định.")
    $(window).resize -> resizeAction()

  destroyed: ->
    $(window).off("resize")
    Session.set("currentActiveModal")

  events:
    "mouseover [wings-tip]": (event, tempate) ->
      Wings.Tip.handleMouseOver($(event.currentTarget))
    "mouseout [wings-tip]": (event, tempate) -> Wings.Tip.handleMouseOut()
    "focus input[side-explain]": (event, template) ->
      $element = $(event.currentTarget)
      Wings.SiderAlert.show $element, $element.attr('side-explain'), $element
    "click": (event, template) -> Session.set("editingId")
resizeAction = ->
  Wings.Component.arrangeLayout()
  $(".nano").nanoScroller()