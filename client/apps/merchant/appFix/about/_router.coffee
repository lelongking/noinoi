FlowRouter.route '/',
  name: 'home'
  action: ->
    console.log 'action'
    console.log Meteor.userId()
    console.log Schema.customers.find().count()
    BlazeLayout.render 'about'
    return
  triggersEnter: [ (context, redirect) ->
    console.log Meteor.user()
    console.log 'running /admin trigger'
    return
  ]
