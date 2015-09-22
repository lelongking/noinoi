Meteor.methods
  SystemInitialization: ->
    Model.System.Initialize()
    Model.Channel.Initialize()
