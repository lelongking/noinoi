#----------Before-Insert---------------------------------------------------------------------------------------------
generateCustomerInitCash = (customer)->
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

generateCustomerInit = (user, customer, splitName)->
  customer.merchant     = user.profile.merchant
  customer.creator      = user._id
  customer.allowDelete  = true

  customer.nameSearch   = Helpers.Searchify(customer.name)
  customer.firstName    = splitName.firstName
  customer.lastName     = splitName.lastName

setCustomerGroupDefault = (user, customer)->
  if !customer.customerOfGroup
    merchantId = user.profile.merchant
    groupBasic = Schema.customerGroups.findOne({merchant: merchantId, isBase: true})
    customer.customerOfGroup = groupBasic._id if groupBasic

#----------After-Insert------------------------------------------------------------------------------------------------
addCustomerInCustomerGroup = (userId, customer) ->
  console.log customer
  if customer.customerOfGroup
    customerGroupUpdate =
      $pull:
        customerLists: customer._id
      $inc:
        debtRequiredCash: customer.debtRequiredCash
        paidRequiredCash: customer.paidRequiredCash
        debtBeginCash   : customer.debtBeginCash
        paidBeginCash   : customer.paidBeginCash
        debtIncurredCash: customer.debtIncurredCash
        paidIncurredCash: customer.paidIncurredCash
        debtSaleCash    : customer.debtSaleCash
        paidSaleCash    : customer.paidSaleCash
        returnSaleCash  : customer.returnSaleCash
    Schema.customerGroups.direct.update(customer.customerOfGroup, customerGroupUpdate)

#----------Before-Update---------------------------------------------------------------------------------------------
updateIsNameChangedOfCustomer = (userId, customer, fieldNames, modifier, options) ->
  if _.contains(fieldNames, "name")
    if customer.name isnt modifier.$set.name
      modifier.$set.nameSearch  = Helpers.Searchify(modifier.$set.name)

      splitName = Helpers.GetFirstNameOrLastName(modifier.$set.name)
      if customer.firstName isnt splitName.firstName
        modifier.$set.firstName = splitName.firstName

      if customer.lastName isnt splitName.lastName
        if Meteor.isServer
          if !modifier.$unset or modifier.$unset.lastName
            modifier.$set.lastName = splitName.lastName
        else
          modifier.$set.lastName  = splitName.lastName

#----------After-Update-------------------------------------------------------------------------------------------------
updateCashOfCustomerGroup = (userId, oldCustomer, newCustomer, fieldNames, modifier, options) ->
  updateOption = $inc:{}

  fieldLists = [
      'debtRequiredCash'
      'paidRequiredCash'
      'debtBeginCash'
      'paidBeginCash'
      'debtIncurredCash'
      'paidIncurredCash'
      'debtSaleCash'
      'paidSaleCash'
      'returnSaleCash'
    ]

  for fieldName in fieldLists
    if oldCustomer[fieldName] isnt newCustomer[fieldName]
      updateOption.$inc[fieldName] = newCustomer[fieldName] - oldCustomer[fieldName]

  if !_.isEmpty(updateOption.$inc)
    Schema.customerGroups.direct.update oldCustomer.customerOfGroup, updateOption

updateCustomerGroup = (userId, oldCustomer, newCustomer, fieldNames, modifier, options) ->
  updateOldCustomerGroup =
    $pull:
      customerLists: oldCustomer.customerOfGroup
    $inc:
      debtRequiredCash: -oldCustomer.debtRequiredCash
      paidRequiredCash: -oldCustomer.paidRequiredCash
      debtBeginCash   : -oldCustomer.debtBeginCash
      paidBeginCash   : -oldCustomer.paidBeginCash
      debtIncurredCash: -oldCustomer.debtIncurredCash
      paidIncurredCash: -oldCustomer.paidIncurredCash
      debtSaleCash    : -oldCustomer.debtSaleCash
      paidSaleCash    : -oldCustomer.paidSaleCash
      returnSaleCash  : -oldCustomer.returnSaleCash
  Schema.customerGroups.direct.update oldCustomer.customerOfGroup, updateOldCustomerGroup


  updateNewCustomerGroup =
    $addToSet:
      customerLists: newCustomer.customerOfGroup
    $inc:
      debtRequiredCash: newCustomer.debtRequiredCash
      paidRequiredCash: newCustomer.paidRequiredCash
      debtBeginCash   : newCustomer.debtBeginCash
      paidBeginCash   : newCustomer.paidBeginCash
      debtIncurredCash: newCustomer.debtIncurredCash
      paidIncurredCash: newCustomer.paidIncurredCash
      debtSaleCash    : newCustomer.debtSaleCash
      paidSaleCash    : newCustomer.paidSaleCash
      returnSaleCash  : newCustomer.returnSaleCash
  Schema.customerGroups.direct.update newCustomer.customerOfGroup, updateNewCustomerGroup

#----------Before-Remove-----------------------------------------------------------------------------------------------
#----------After-Remove-------------------------------------------------------------------------------------------------
removeCashOfCustomerCash = (userId, customer)->
  if customer.customerOfGroup
    customerGroupUpdate =
      $addToSet:
        customerLists: customer._id
      $inc:
        debtRequiredCash: -customer.debtRequiredCash
        paidRequiredCash: -customer.paidRequiredCash
        debtBeginCash   : -customer.debtBeginCash
        paidBeginCash   : -customer.paidBeginCash
        debtIncurredCash: -customer.debtIncurredCash
        paidIncurredCash: -customer.paidIncurredCash
        debtSaleCash    : -customer.debtSaleCash
        paidSaleCash    : -customer.paidSaleCash
        returnSaleCash  : -customer.returnSaleCash
    Schema.customerGroups.direct.update(customer.customerOfGroup, customerGroupUpdate)



#-----------------------------------------------------------------------------------------------------------------------
Schema.customers.before.insert (userId, customer)->
  user = Meteor.users.findOne(userId)
  splitName = Helpers.GetFirstNameOrLastName(customer.name)
  generateCustomerInit(user, customer, splitName)
  generateCustomerInitCash(customer)
  generateOrderStatus(customer)
  setCustomerGroupDefault(user, customer)

Schema.customers.after.insert (userId, customer) ->
  addCustomerInCustomerGroup(userId, customer)

#-----------------------------------------------------------------------------------------------------------------------
Schema.customers.before.update (userId, customer, fieldNames, modifier, options) ->
  updateIsNameChangedOfCustomer(userId, customer, fieldNames, modifier, options)

Schema.customers.after.update (userId, newCustomer, fieldNames, modifier, options) ->
  oldCustomer = @previous
  isChangeCustomerGroup = oldCustomer.customerOfGroup isnt newCustomer.customerOfGroup

  if isChangeCustomerGroup
    updateCashOfCustomerGroup(userId, oldCustomer, newCustomer, fieldNames, modifier, options)
  else
    updateCustomerGroup(userId, oldCustomer, newCustomer, fieldNames, modifier, options)

#-----------------------------------------------------------------------------------------------------------------------
Schema.customers.before.remove (userId, customer) ->

Schema.customers.after.remove (userId, doc)->
  removeCashOfCustomerCash(userId, doc)