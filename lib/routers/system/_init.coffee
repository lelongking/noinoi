Wings.Routers.systemRouter =
  Wings.Routers.loggedInRouter.group
    prefix: '/system'
    name: "system"
    triggersEnter: [ (context, redirect, stop) ->
      return
    ]