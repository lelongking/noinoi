generateInitCash = (customer)->
  customer.debtRequiredCash = 0
  customer.paidRequiredCash = 0
  customer.debtBeginCash    = 0
  customer.paidBeginCash    = 0
  customer.debtIncurredCash = 0
  customer.paidIncurredCash = 0
  customer.debtSaleCash     = 0
  customer.paidSaleCash     = 0
  customer.returnSaleCash   = 0

generateOrderStatus = (customer)->
  customer.orderWaiting = []
  customer.orderFailure = []
  customer.orderSuccess = []

generateInit = (user, customer, splitName)->
  customer.merchant     = user.profile.merchant
  customer.creator      = user._id
  customer.allowDelete  = true

  customer.nameSearch   = Helpers.Searchify(customer.name)
  customer.firstName    = splitName.firstName
  customer.lastName     = splitName.lastName



Schema.customers.before.insert (userId, doc)->
  console.log 'before insert'
  user = Meteor.users.findOne(userId)
  splitName = Helpers.GetFirstNameOrLastName(doc.name)
  generateInit(user, doc, splitName)
  generateInitCash(doc)
  generateOrderStatus(doc)

Schema.customers.after.insert (userId, doc)->



Schema.customers.before.update (userId, doc, fieldNames, modifier, options)->
  console.log 'before update'
  #  console.log userId, doc, fieldNames, modifier, options
  if _.contains(fieldNames, "name")
    if doc.name isnt modifier.$set.name
      modifier.$set.nameSearch  = Helpers.Searchify(modifier.$set.name)

      splitName = Helpers.GetFirstNameOrLastName(modifier.$set.name)
      if doc.firstName isnt splitName.firstName
        modifier.$set.firstName = splitName.firstName

      if doc.lastName isnt splitName.lastName
        modifier.$set.lastName  = splitName.lastName

  console.log modifier