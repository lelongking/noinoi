Module 'Wings.RouterFilters',
  authenticate: (context, redirect, stop) ->
    user = undefined
    if Meteor.loggingIn()
      console.log '[authenticate filter] loading'
      BlazeLayout.render 'noHeaderLayout', content: 'not_found'
      stop()
    else
      user = Meteor.user()
      if !user
        console.log '[authenticate filter] signin'
        #this.layout('layout_no_header')
        #this.render('signin')
        return
      if !emailVerified(user)
        console.log '[authenticate filter] awaiting-verification'
      #this.layout('layout')
      #this.render('awaiting-verification')
      #return
      console.log '[authenticate filter] done'
      loggedInUser = Meteor.user()
      console.log Roles.userIsInRole(loggedInUser, [
        'admin'
        'manage-users'
      ])
    #this.layout('layout')
    #this.next()
    return

  testFilter: (context, redirect) ->
    console.log '[test filter]'
    #this.next()
    return

emailVerified = (user) ->
  _.some user.emails, (email) ->
    email.verified



