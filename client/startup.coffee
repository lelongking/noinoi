Meteor.startup ->
  moment.locale('vi')
#  Meteor.call('trackingProduct')

  Tracker.autorun ->
#    accountStatus = AccountStatus.findOne({_id: Accounts.connection._lastSessionId})
#    if accountStatus?.userId
#      accountLastActivity = AccountStatus.findOne
#        userId   : accountStatus.userId
#        ipAddr   : accountStatus.ipAddr
#        userAgent: accountStatus.userAgent
#      ,
#        sort:
#          lastActivity: 1
#
#      console.log accountStatus.idle
#      console.log accountLastActivity.idle


    if Meteor.userId()
      user = Meteor.users.findOne(Meteor.userId())
      Session.set 'myUser', user

      if user?.sessions
        user.sessions._id = user._id
        Session.set 'mySession', user.sessions

      if user?.profile
        user.profile._id = user._id
        Session.set 'myProfile', user.profile

        if user.profile.merchant
          priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: user.profile.merchant})
          Session.set 'priceBookBasic', priceBookBasic

          merchant = Schema.merchants.findOne(user.profile.merchant)
          Session.set 'merchant', merchant


      unless Session.get('mySession')
        if user = Meteor.users.findOne(Meteor.userId())
          user.sessions._id = user._id
          Session.set 'mySession', user.sessions

      unless Session.get('myProfile')
        if user = Meteor.users.findOne(Meteor.userId())
          user.profile._id = user._id
          Session.set 'myProfile', user.profile

    else
      if Session.get('loggedIn')
        # get and save the current route
        route = FlowRouter.current()
        Session.set 'redirectAfterLogin', route.path
        FlowRouter.go FlowRouter.path('login')