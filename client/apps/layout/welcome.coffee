Wings.defineWidget "WelcomeLayout",
  events:
    "mouseover [wings-tip]": (event, tempate) ->
      Wings.Tip.handleMouseOver($(event.currentTarget))
    "mouseout [wings-tip]": (event, tempate) -> Wings.Tip.handleMouseOut()