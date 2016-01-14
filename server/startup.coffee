Meteor.startup ->
  #//////////////////////////////////////////////////////////////////
  # Create Test Secrets
  #
#  if Meteor.secrets.find().fetch().length == 0
#    Meteor.secrets.insert secret: 'ec2 password: apple2'
#    Meteor.secrets.insert secret: 'domain registration pw: apple3'
  #////////////////////////////////////////////////////////////////
  # Create Test Users
  #
#  if Meteor.users.find().fetch().length == 0
#    console.log 'Creating users: '
#    users = [
#      {
#        name: 'Normal User'
#        email: 'normal@example.com'
#        roles: []
#      }
#      {
#        name: 'View-Secrets User'
#        email: 'view@example.com'
#        roles: [ 'view-secrets' ]
#      }
#      {
#        name: 'Manage-Users User'
#        email: 'manage@example.com'
#        roles: [ 'manage-users' ]
#      }
#      {
#        name: 'Admin User'
#        email: 'admin@example.com'
#        roles: [ 'admin' ]
#      }
#    ]
#    _.each users, (userData) ->
#      id = undefined
#      user = undefined
#      console.log userData
#      id = Accounts.createUser(
#        email: userData.email
#        password: 'apple1'
#        profile: name: userData.name)
#      # email verification
#      Meteor.users.update { _id: id }, $set: 'emails.0.verified': true
#      Roles.addUsersToRoles id, userData.roles
#      return
  #//////////////////////////////////////////////////////////////////
  # Prevent non-authorized users from creating new users
  #

  Accounts.validateNewUser (user) ->
    loggedInUser = Meteor.user()
    if loggedInUser
      return true #if Roles.userIsInRole(loggedInUser, Wings.Roles.isCreateMerchantUser)
      console.log 'Not authorized to create new users'
      throw new (Meteor.Error)(403, 'Not authorized to create new users')
      return
    else
      return true
  return



if Meteor.roles.find().count() < 1
  for role in [
    'super-admin'
    'merchant-admin'
    'merchant-manage'
    'merchant-sales'
    'merchant-accounting'
    'merchant-warehouses'
  ]
    Roles.createRole(role)