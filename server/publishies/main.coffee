Enums = Apps.Merchant.Enums
Meteor.publish null, ->
  collections = []
  return collections if !@userId
  myProfile  = Meteor.users.findOne(@userId)?.profile
  merchantId = myProfile.merchant if myProfile
  return collections if !merchantId

  collections.push Schema.notifications.find({merchant: merchantId})
  collections.push Schema.messages.find({receiver: @userId}, {sort: {'version.createdAt': -1}, limit: 10})
  collections.push Schema.merchants.find({_id: merchantId})
  collections.push AvatarImages.find()
  collections.push Schema.products.find({merchant: merchantId})
  collections.push Schema.productGroups.find({merchant: merchantId})
  collections.push Schema.customers.find({merchant: merchantId})
  collections.push Schema.customerGroups.find({merchant: merchantId})
  collections.push Schema.providers.find({merchant: merchantId})
  collections.push Schema.returns.find({merchant: merchantId})
  collections.push Schema.orders.find({merchant: merchantId})
  collections.push Schema.imports.find({merchant: merchantId})
  collections.push Schema.priceBooks.find({merchant: merchantId})
  collections.push Schema.transactions.find({merchant: merchantId})
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