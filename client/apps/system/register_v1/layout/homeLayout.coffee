Wings.defineWidget 'homeLayout',
  rendered: -> $("body").css("overflow-y", "scroll")
  destroyed: -> $("body").css("overflow-y", "hidden")