Routers = Wings.Routers = {}
Wings.SubsManager = new SubsManager({cacheLimit: 9999, expireIn: 9999})

#----------------------------------------------------------------------------------------------
publicRouter = Wings.Routers.publicRouter =
  FlowRouter.group
    name: "public"
    triggersEnter: [ (context, redirect, stop) ->
      console.log context.path, context.queryParams
      if context.path is '/'
        location.reload()
      else
        if Meteor.userId()
          redirect '/merchant'
        else
          redirect '/merchant/login'
      stop()
      return
    ]

publicRouter.route '/',
  name: 'home'
  action: ->
    location.reload()
#    BlazeLayout.render 'homeLayout'
    return
  triggersEnter: [ (context, redirect) ->
#    location.reload()
#    if Meteor.userId()
#      redirect '/merchant'
#    else
#      redirect '/merchant/login'
#    stop()
    return
  ]

#publicRouter.route '/merchant/login',
#  name: 'login'
#  action: (params, queryParams) ->
#    BlazeLayout.render 'login_v01'
##    if queryParams.version is 'login_v01'
##      BlazeLayout.render 'login_v01'
##    else
##      BlazeLayout.render 'notFound'
#  triggersEnter: [ (context, redirect, stop) ->
#    console.log context
##    unless context.queryParams.version
##      BlazeLayout.render 'login_v01'
##      stop()
#  ]

#----------------------------------------------------------------------------------------------
Routers.loggedInRouter =
  FlowRouter.group
    name: "loggedIn"
    triggersEnter: [ (context, redirect, stop) ->
#      unless Meteor.loggingIn() or Meteor.userId()
#        route = FlowRouter.current()
#        unless route.route.name is 'login'
#          Session.set 'redirectAfterLogin', route.path
#        redirect 'login'
#        stop()
      return
    ]

FlowRouter.notFound =
  subscriptions: ->
  action: ->
    BlazeLayout.render 'notFound'