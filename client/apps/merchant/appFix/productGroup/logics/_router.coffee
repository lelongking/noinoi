FlowRouter.route '/productGroup',
  name: 'productGroup'
  action: ->
    Session.set "currentAppInfo",
      name: "nhóm sản phẩm"

    BlazeLayout.render 'merchantLayout',
      content: 'productGroup'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

