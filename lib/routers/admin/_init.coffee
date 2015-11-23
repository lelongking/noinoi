adminRouter = Wings.Routers.adminRouter =
  Wings.Routers.loggedInRouter.group
    prefix: '/admin'
    name: "admin"
    triggersEnter: [ (context, redirect, stop) ->
#      unless Roles.userIsInRole Meteor.user(), [ 'admin' ]
#        redirect FlowRouter.path('login')
#        stop()
    ]

adminRouter.route '/',
  name: 'admin'
  action: ->

adminRouter.route '/users',
  name: 'users'
  action: ->
    BlazeLayout.render 'users'