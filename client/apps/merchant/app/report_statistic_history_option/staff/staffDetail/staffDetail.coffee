scope = logics.staffManagement
Enums = Apps.Merchant.Enums

Wings.defineApp 'staffDetail',
  created: ->

  helpers:
    currentStaff: ->
      staffId = Session.get('mySession')?.currentStaff
      Meteor.users.findOne({_id:staffId})