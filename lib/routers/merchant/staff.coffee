merchantRouter = Wings.Routers.merchantRouter

merchantRouter.route '/staff',
  name: 'staff'
  action: ->
    Session.set "currentAppInfo",
      name: "nhân sự"

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'staffSearch'
        contentDetail: 'staffDetail'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]

merchantRouter.route '/staff/create',
  name: 'createStaff'
  action: ->
    Session.set "currentAppInfo",
      name: "nhân sự"

    BlazeLayout.render 'merchantLayout',
      content: 'contentDefaultLayout'
      contentData:
        contentAddon: 'staffSearch'
        contentDetail: 'staffCreate'
    return

  triggersEnter: [ (context, redirect) ->
    console.log 'running /provider trigger'
    return
  ]