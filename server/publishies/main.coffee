Enums = Apps.Merchant.Enums
Meteor.publish null, ->
  collections = []
  return collections if !@userId
  myProfile  = Meteor.users.findOne(@userId)?.profile
  merchantId = myProfile.merchant if myProfile
  return collections if !merchantId

  collections.push Schema.notifications.find()
  collections.push Schema.messages.find({receiver: @userId}, {sort: {'version.createdAt': -1}, limit: 10})
  collections.push Schema.merchants.find({_id: merchantId})
  collections.push AvatarImages.find({})
  collections.push Schema.products.find()
  collections.push Schema.productGroups.find()
  collections.push Schema.customers.find()
  collections.push Schema.customerGroups.find()
  collections.push Schema.providers.find()
  collections.push Schema.returns.find()
  collections.push Schema.orders.find()
  collections.push Schema.imports.find()
  collections.push Schema.priceBooks.find()
  collections.push Schema.transactions.find()
  collections.push Meteor.users.find({'profile.merchant': merchantId}, {fields: {
    emails:1, profile: 1, sessions: 1, creator: 1, status: 1, allowDelete : 1
  } })

  return collections

Meteor.publish 'secrets', ->
  user = Meteor.users.findOne(_id: @userId)
  if Roles.userIsInRole(user, [
    'admin'
    'view-secrets'
  ])
    console.log 'publishing secrets', @userId
    return Meteor.secrets.find()
  @stop()
  return