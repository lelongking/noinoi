safeSessions = []

Module 'Wings',
  listSession: -> console.log key for key, obj of Session.keys
  cleanSession: ->
    console.log 'cleaning sessions'
    Session.keys[key] = null for key, obj of Session.keys when !_.contains(safeSessions, key)
  logout: (redirectUrl = '/') ->
    Meteor.logout()
    Wings.setupHistories = []
    Wings.cleanSession()
    Meteor.setTimeout ->
      FlowRouter.go(redirectUrl) if redirectUrl
    , 1000