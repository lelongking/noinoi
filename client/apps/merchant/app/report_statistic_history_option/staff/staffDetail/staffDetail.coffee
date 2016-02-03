scope = logics.staffManagement
Enums = Apps.Merchant.Enums

Wings.defineApp 'staffDetail',
  created: ->

  helpers:
    currentStaff: ->
      staffId = Session.get('mySession')?.currentStaff
      if staffId
        Meteor.users.findOne({_id:staffId})
      else
        Meteor.users.findOne({_id:Meteor.userId()})