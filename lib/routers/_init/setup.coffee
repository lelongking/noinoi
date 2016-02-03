Routers = Wings.Routers = {}
Wings.SubsManager = new SubsManager({cacheLimit: 9999, expireIn: 9999})

#----------------------------------------------------------------------------------------------
publicRouter = Wings.Routers.publicRouter =
  FlowRouter.group
    name: "public"
    triggersEnter: [ (context, redirect, stop) ->
      if Meteor.userId()
        redirect '/merchant'
        stop()
      return
    ]

publicRouter.route '/',
  name: 'home'
  action: ->
    BlazeLayout.render 'homeLayout'
    return
  triggersEnter: [ (context, redirect) ->
    if Meteor.userId()
      redirect '/merchant'
      stop()

    return
  ]

publicRouter.route '/register',
  name: 'register'
  action: ->
    BlazeLayout.render 'homeLayout'

publicRouter.route '/login',
  name: 'login'
  action: (params, queryParams)->
    if queryParams.version is 'login_v01'
      BlazeLayout.render 'login_v01'
    else
      BlazeLayout.render 'notFound'
  triggersEnter: [ (context, redirect, stop) ->
    unless context.queryParams.version
      BlazeLayout.render 'login_v01'
      stop()
  ]

#----------------------------------------------------------------------------------------------
Routers.loggedInRouter =
  FlowRouter.group
    name: "loggedIn"
    triggersEnter: [ (context, redirect, stop) ->
      $(".tooltip").remove()
      Helpers.arrangeAppLayout()

      unless Meteor.loggingIn() or Meteor.userId()
        route = FlowRouter.current()
        unless route.route.name is 'login'
          Session.set 'redirectAfterLogin', route.path
        redirect '/login'
        stop()
      return
    ]

FlowRouter.notFound =
  subscriptions: ->
  action: ->
    BlazeLayout.render 'notFound'