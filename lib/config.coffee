if Meteor.isClient
  # Create Database Account Status tracking online users only
  @AccountStatus = new Mongo.Collection("user_status_sessions")
  @AccountStatus.allow
    insert: (userId, doc)-> true
    update: (userId, doc)-> true
    remove: (userId, doc)-> true

  # Start monitor as soon as we got a signal, captain!
  Deps.autorun (c) ->
    try # May be an error if time is not synced
      UserStatus.startMonitor
        threshold: 30000
        idleOnBlur: true
      c.stop()

if Meteor.isServer
  process.env.HTTP_FORWARDED_COUNT = 1
  Meteor.publish null, ->
    [
      Meteor.users.find { "status.online": true }, # online users only
        fields:
          status: 1,
          username: 1
      UserStatus.connections.find()
    ]



if Meteor.isClient
  BlazeLayout.setRoot('body')

  # Only login in one browser
  Accounts.onLogin (user) ->
    accountStatus = AccountStatus.findOne({_id: Accounts.connection._lastSessionId})
    statusBrowsers = Meteor.user().sessions.statusBrowsers

    browserOption = {ipAddr: accountStatus.ipAddr, userAgent: accountStatus.userAgent}

    if accountStatus and statusBrowsers
      if findBrowser = _.findWhere(statusBrowsers, browserOption)
        if findBrowser.status
        else
      else
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.statusBrowsers': orderId}})



    #Todo: xem lai ??? 1 browser mo hai tab van bi
    #    # logout other clients
    #    Meteor.logoutOtherClients()
    #    Session.set 'loggedIn', true

    redirect = Session.get 'redirectAfterLogin'
    if redirect?
      unless redirect is '/login'
        FlowRouter.go redirect
