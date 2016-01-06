customerCalculateTotalCash = (customer) ->
  saleCash                = (customer.saleAmount ? 0) + (customer.returnPaidAmount ? 0) - (customer.returnAmount ? 0)
  customer.debitCash      = saleCash + (customer.loanAmount ? 0)
  customer.interestCash   = (customer.interestAmount ? 0)
  customer.paidCash       = (customer.paidAmount ? 0)
  customer.totalDebitCash = (customer.initialAmount ? 0) + customer.debitCash
  customer.totalCash      = customer.totalDebitCash + customer.interestCash - customer.paidCash
  customer

#----------Before-Insert---------------------------------------------------------------------------------------------
generateCustomerCode = (user, customer, summaries)->
  lastCustomerCode  = summaries.lastCustomerCode ? 0
  listCustomerCodes = summaries.listCustomerCodes ? []

  customer.code = (customer.code ? '').replace(/^\s*/, "").replace(/\s*$/, "")
  if customer.code.length is 0 or _.indexOf(listCustomerCodes, customer.code) > -1
    customer.code = Wings.Helper.checkAndGenerateCode(lastCustomerCode, listCustomerCodes)


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
#
#
#Schema.customers.before.find (userId, selector, options)->
#  console.log 'before'
#  console.log userId, selector, options
#
#Schema.customers.after.find (userId, selector, options, cursor)->
#  console.log 'after'
#  console.log cursor.collection


Schema.customers.before.insert (userId, customer)->
  user      = Meteor.users.findOne({_id:userId})
  splitName = Helpers.GetFirstNameOrLastName(customer.name)
  merchant  = Schema.merchants.findOne({_id: user.profile.merchant})

  generateCustomerCode(user, customer, merchant.summaries)
  generateCustomerInit(user, customer, splitName)
  generateCustomerInitCash(customer)
  generateOrderStatus(customer)
  customer = customerCalculateTotalCash(customer)
  setCustomerGroupDefault(user, customer)








#----------After-Insert------------------------------------------------------------------------------------------------
addCustomerInCustomerGroup = (userId, customer) ->
  console.log customer
  if customer.customerOfGroup
    customerGroupUpdate =
      $addToSet:
        customerLists: customer._id
      $inc:
        totalCash: customer.totalCash
    Schema.customerGroups.direct.update(customer.customerOfGroup, customerGroupUpdate)

addCustomerCodeInMerchantSummary = (userId, customer) ->
  if customer.code
    Schema.merchants.direct.update customer.merchant, $addToSet: {'summaries.listCustomerCodes': customer.code}
  if customer.phone
    Schema.merchants.direct.update customer.merchant, $addToSet: {'summaries.listCustomerPhones': customer.phone}


Schema.customers.after.insert (userId, customer) ->
  customer = customerCalculateTotalCash(customer)
  addCustomerInCustomerGroup(userId, customer)
  addCustomerCodeInMerchantSummary(userId, customer)











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

Schema.customers.before.update (userId, customer, fieldNames, modifier, options) ->
  customer = customerCalculateTotalCash(customer)
  updateIsNameChangedOfCustomer(userId, customer, fieldNames, modifier, options)











#----------After-Update-------------------------------------------------------------------------------------------------
updateCustomerGroup = (userId, oldCustomer, newCustomer, fieldNames, modifier, options) ->

  updateOption =
    $inc:
      totalCash: newCustomer.totalCash - oldCustomer.totalCash

  console.log 'caculator update', updateOption.$inc.totalCash is 0
  console.log updateOption, newCustomer.totalCash, oldCustomer.totalCash

  if updateOption.$inc.totalCash isnt 0
    console.log oldCustomer.customerOfGroup
    console.log Schema.customerGroups.direct.update(oldCustomer.customerOfGroup, updateOption)

updateCashOfCustomerGroup = (userId, oldCustomer, newCustomer, fieldNames, modifier, options) ->
  updateOldCustomerGroup =
    $pull:
      customerLists: oldCustomer.customerOfGroup
    $inc:
      totalCash: -oldCustomer.totalCash
  console.log updateOldCustomerGroup
  Schema.customerGroups.direct.update oldCustomer.customerOfGroup, updateOldCustomerGroup


  updateNewCustomerGroup =
    $addToSet:
      customerLists: newCustomer.customerOfGroup
    $inc:
      totalCash: newCustomer.totalCash
  console.log updateNewCustomerGroup
  Schema.customerGroups.direct.update newCustomer.customerOfGroup, updateNewCustomerGroup

updateCustomerCodeInMerchantSummary = (userId, oldCustomer, newCustomer) ->
  if oldCustomer.code isnt newCustomer.code
    Schema.merchants.direct.update customer.merchant, $pull: {'summaries.listCustomerCodes': oldCustomer.code}
    Schema.merchants.direct.update customer.merchant, $addToSet: {'summaries.listCustomerCodes': newCustomer.code}



Schema.customers.after.update (userId, newCustomer, fieldNames, modifier, options) ->
  if Meteor.isServer
    oldCustomer = @previous
    isChangeCustomerGroup = oldCustomer.customerOfGroup isnt newCustomer.customerOfGroup
    oldCustomer = customerCalculateTotalCash(oldCustomer)
    newCustomer = customerCalculateTotalCash(newCustomer)


    if isChangeCustomerGroup
  #    updateCashOfCustomerGroup(userId, oldCustomer, newCustomer, fieldNames, modifier, options)
    else
      updateCustomerGroup(userId, oldCustomer, newCustomer, fieldNames, modifier, options)


    updateCustomerCodeInMerchantSummary(userId, oldCustomer, newCustomer)








#----------Before-Remove-----------------------------------------------------------------------------------------------
Schema.customers.before.remove (userId, customer) ->










#----------After-Remove-------------------------------------------------------------------------------------------------
removeCashOfCustomerCash = (userId, customer)->
  if customer.customerOfGroup
    customerGroupUpdate =
      $pull:
        customerLists: customer._id
      $inc:
        totalCash: -customer.totalCash
    Schema.customerGroups.direct.update(customer.customerOfGroup, customerGroupUpdate)

removeCustomerCodeAndPhoneInMerchantSummary = (userId, customer)->
  if customer.code
    Schema.merchants.direct.update customer.merchant, $pull: {'summaries.listCustomerCodes': customer.code}
  if customer.phone
    Schema.merchants.direct.update customer.merchant, $pull: {'summaries.listCustomerPhones': customer.phone}

Schema.customers.after.remove (userId, customer)->
  removeCashOfCustomerCash(userId, customer)
  removeCustomerCodeAndPhoneInMerchantSummary(userId, customer)