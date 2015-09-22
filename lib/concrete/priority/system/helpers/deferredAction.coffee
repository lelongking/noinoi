Module 'Wings.Helper',
  DeferredAction: (action, uniqueName, timeOut = 200) ->
    Meteor.clearTimeout(@currentDefferedTimeout) if @currentDefferedActionName is uniqueName

    @currentDefferedTimeout = Meteor.setTimeout ->
      action()
    , timeOut

    @currentDefferedActionName = uniqueName if uniqueName