Enums = Apps.Merchant.Enums
Meteor.methods
  createUserByEmail: (email, password, profile = {})->
    profile.gender   = true if profile.gender is undefined
    profile.name     = email if !profile.name
    profile.merchant = Merchant.getId()
    profile.role     = Enums.getObject('PermissionType').accounting.value

    userId = Accounts.createUser {email: email, password: password, profile: profile}
    userId