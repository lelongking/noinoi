FlowRouter.route '/',
  name: 'home'
  action: ->
    BlazeLayout.render 'about'
    return
  triggersEnter: [ (context, redirect) ->
    console.log 'running /admin trigger'
    return
  ]
