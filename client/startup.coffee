Meteor.startup ->
  moment.locale('vi')

  Meteor.call('trackingProduct')

  Tracker.autorun ->
    if Meteor.userId()
      user = Meteor.users.findOne(Meteor.userId())
      Session.set 'myUser', user

      if user?.sessions
        user.sessions._id = user._id
        Session.set 'mySession', user.sessions

      if user?.profile
        user.profile._id = user._id
        Session.set 'myProfile', user.profile

        Session.set 'merchant', Schema.merchants.findOne(user.profile.merchant)
        Session.set 'priceBookBasic', Schema.priceBooks.findOne({priceBookType: 0, merchant: user.profile.merchant})


      unless Session.get('mySession')
        if user = Meteor.users.findOne(Meteor.userId())
          user.sessions._id = user._id
          Session.set 'mySession', user.sessions

      unless Session.get('myProfile')
        if user = Meteor.users.findOne(Meteor.userId())
          user.profile._id = user._id
          Session.set 'myProfile', user.profile