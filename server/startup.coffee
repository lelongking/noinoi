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
    if Roles.userIsInRole(loggedInUser, Wings.Roles.isCreateMerchantUser)
      return true
    console.log 'false'
    throw new (Meteor.Error)(403, 'Not authorized to create new users')
    return
  return



if Meteor.roles.find().count() < 1
  for role in [
    'merchant-admin'
    'merchant-super-manage'
    'merchant-manage-users'
    'merchant-manage-sales'
    'merchant-manage-warehouses'
    'merchant-manage-accounting'
    'merchant-manage-deliveries'
  ]
    Roles.createRole(role)