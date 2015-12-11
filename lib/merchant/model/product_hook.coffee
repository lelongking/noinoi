##----------Before-Insert---------------------------------------------------------------------------------------------
#generateCustomerCode = (user, customer)->
#
#generateCustomerInitCash = (customer)->
#  customer.debtRequiredCash = 0
#  customer.paidRequiredCash = 0
#  customer.debtBeginCash    = 0
#  customer.paidBeginCash    = 0
#  customer.debtIncurredCash = 0
#  customer.paidIncurredCash = 0
#  customer.debtSaleCash     = 0
#  customer.paidSaleCash     = 0
#  customer.returnSaleCash   = 0
#
#generateOrderStatus = (customer)->
#  customer.orderWaiting = []
#  customer.orderFailure = []
#  customer.orderSuccess = []
#
#generateCustomerInit = (user, customer, splitName)->
#  customer.merchant     = user.profile.merchant
#  customer.creator      = user._id
#  customer.allowDelete  = true
#
#  customer.nameSearch   = Helpers.Searchify(customer.name)
#  customer.firstName    = splitName.firstName
#  customer.lastName     = splitName.lastName
#
#setCustomerGroupDefault = (user, customer)->
#  if !customer.customerOfGroup
#    merchantId = user.profile.merchant
#    groupBasic = Schema.customerGroups.findOne({merchant: merchantId, isBase: true})
#    customer.customerOfGroup = groupBasic._id if groupBasic
#
#Schema.customers.before.insert (userId, customer)->
#  user      = Meteor.users.findOne({_id:userId})
#  merchant  = Schema.merchants.findOne({_id: user.profile.merchant})
#  splitName = Helpers.GetFirstNameOrLastName(customer.name)
#
#  lastCode          = merchant.summaries.lastCustomerCode ? 0
#  listCustomerCodes = merchant.summaries.listCustomerCodes ? []
#  customer.code     = Wings.Helper.checkAndGenerateCode(lastCode, listCustomerCodes)
#
#  generateCustomerCode(user, customer)
#  generateCustomerInit(user, customer, splitName)
#  generateCustomerInitCash(customer)
#  generateOrderStatus(customer)
#  setCustomerGroupDefault(user, customer)
#########################################################################################################################
#
#
#
##----------After-Insert------------------------------------------------------------------------------------------------
#addCustomerInCustomerGroup = (userId, customer) ->
#  console.log customer
#  if customer.customerOfGroup
#    customerGroupUpdate =
#      $addToSet:
#        customerLists: customer._id
#      $inc:
#        debtRequiredCash: customer.debtRequiredCash
#        paidRequiredCash: customer.paidRequiredCash
#        debtBeginCash   : customer.debtBeginCash
#        paidBeginCash   : customer.paidBeginCash
#        debtIncurredCash: customer.debtIncurredCash
#        paidIncurredCash: customer.paidIncurredCash
#        debtSaleCash    : customer.debtSaleCash
#        paidSaleCash    : customer.paidSaleCash
#        returnSaleCash  : customer.returnSaleCash
#    Schema.customerGroups.direct.update(customer.customerOfGroup, customerGroupUpdate)
#
#addCustomerCodeInMerchantSummary = (userId, customer) ->
#  if customer.code
#    Schema.merchants.direct.update customer.merchant, $addToSet: {'summaries.listCustomerCodes': customer.code}
#
#
#Schema.customers.after.insert (userId, customer) ->
#  addCustomerInCustomerGroup(userId, customer)
#  addCustomerCodeInMerchantSummary(userId, customer)
#########################################################################################################################
#
#
#
##----------Before-Update---------------------------------------------------------------------------------------------
#updateIsNameChangedOfCustomer = (userId, customer, fieldNames, modifier, options) ->
#  if _.contains(fieldNames, "name")
#    if customer.name isnt modifier.$set.name
#      modifier.$set.nameSearch  = Helpers.Searchify(modifier.$set.name)
#
#      splitName = Helpers.GetFirstNameOrLastName(modifier.$set.name)
#      if customer.firstName isnt splitName.firstName
#        modifier.$set.firstName = splitName.firstName
#
#      if customer.lastName isnt splitName.lastName
#        if Meteor.isServer
#          if !modifier.$unset or modifier.$unset.lastName
#            modifier.$set.lastName = splitName.lastName
#        else
#          modifier.$set.lastName  = splitName.lastName
#
#Schema.customers.before.update (userId, customer, fieldNames, modifier, options) ->
#  updateIsNameChangedOfCustomer(userId, customer, fieldNames, modifier, options)
#########################################################################################################################
#
#
#
##----------After-Update-------------------------------------------------------------------------------------------------
#updateCashOfCustomerGroup = (userId, oldCustomer, newCustomer, fieldNames, modifier, options) ->
#  updateOption = $inc:{}
#
#  fieldLists = [
#      'debtRequiredCash'
#      'paidRequiredCash'
#      'debtBeginCash'
#      'paidBeginCash'
#      'debtIncurredCash'
#      'paidIncurredCash'
#      'debtSaleCash'
#      'paidSaleCash'
#      'returnSaleCash'
#    ]
#
#  for fieldName in fieldLists
#    if oldCustomer[fieldName] isnt newCustomer[fieldName]
#      updateOption.$inc[fieldName] = newCustomer[fieldName] - oldCustomer[fieldName]
#
#  if !_.isEmpty(updateOption.$inc)
#    Schema.customerGroups.direct.update oldCustomer.customerOfGroup, updateOption
#
#updateCustomerGroup = (userId, oldCustomer, newCustomer, fieldNames, modifier, options) ->
#  updateOldCustomerGroup =
#    $pull:
#      customerLists: oldCustomer.customerOfGroup
#    $inc:
#      debtRequiredCash: -oldCustomer.debtRequiredCash
#      paidRequiredCash: -oldCustomer.paidRequiredCash
#      debtBeginCash   : -oldCustomer.debtBeginCash
#      paidBeginCash   : -oldCustomer.paidBeginCash
#      debtIncurredCash: -oldCustomer.debtIncurredCash
#      paidIncurredCash: -oldCustomer.paidIncurredCash
#      debtSaleCash    : -oldCustomer.debtSaleCash
#      paidSaleCash    : -oldCustomer.paidSaleCash
#      returnSaleCash  : -oldCustomer.returnSaleCash
#  Schema.customerGroups.direct.update oldCustomer.customerOfGroup, updateOldCustomerGroup
#
#
#  updateNewCustomerGroup =
#    $addToSet:
#      customerLists: newCustomer.customerOfGroup
#    $inc:
#      debtRequiredCash: newCustomer.debtRequiredCash
#      paidRequiredCash: newCustomer.paidRequiredCash
#      debtBeginCash   : newCustomer.debtBeginCash
#      paidBeginCash   : newCustomer.paidBeginCash
#      debtIncurredCash: newCustomer.debtIncurredCash
#      paidIncurredCash: newCustomer.paidIncurredCash
#      debtSaleCash    : newCustomer.debtSaleCash
#      paidSaleCash    : newCustomer.paidSaleCash
#      returnSaleCash  : newCustomer.returnSaleCash
#  Schema.customerGroups.direct.update newCustomer.customerOfGroup, updateNewCustomerGroup
#
#Schema.customers.after.update (userId, newCustomer, fieldNames, modifier, options) ->
#  oldCustomer = @previous
#  isChangeCustomerGroup = oldCustomer.customerOfGroup isnt newCustomer.customerOfGroup
#
#  if isChangeCustomerGroup
#    updateCashOfCustomerGroup(userId, oldCustomer, newCustomer, fieldNames, modifier, options)
#  else
#    updateCustomerGroup(userId, oldCustomer, newCustomer, fieldNames, modifier, options)
#########################################################################################################################
#
#
#
##----------Before-Remove-----------------------------------------------------------------------------------------------
#Schema.customers.before.remove (userId, customer) ->
#########################################################################################################################
#
#
#
##----------After-Remove-------------------------------------------------------------------------------------------------
#removeCashOfCustomerCash = (userId, customer)->
#  if customer.customerOfGroup
#    customerGroupUpdate =
#      $pull:
#        customerLists: customer._id
#      $inc:
#        debtRequiredCash: -customer.debtRequiredCash
#        paidRequiredCash: -customer.paidRequiredCash
#        debtBeginCash   : -customer.debtBeginCash
#        paidBeginCash   : -customer.paidBeginCash
#        debtIncurredCash: -customer.debtIncurredCash
#        paidIncurredCash: -customer.paidIncurredCash
#        debtSaleCash    : -customer.debtSaleCash
#        paidSaleCash    : -customer.paidSaleCash
#        returnSaleCash  : -customer.returnSaleCash
#    Schema.customerGroups.direct.update(customer.customerOfGroup, customerGroupUpdate)
#
#Schema.customers.after.remove (userId, doc)->
#  removeCashOfCustomerCash(userId, doc)
#########################################################################################################################