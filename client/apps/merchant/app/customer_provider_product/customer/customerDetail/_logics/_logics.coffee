logics.customerManagement = {} unless logics.customerManagement
Enums = Apps.Merchant.Enums
scope = logics.customerManagement
scope.customerLists = []

scope.resetShowEditCommand = -> Session.set "customerManagementShowEditCommand"
scope.transactionFind = (parentId)->
  Schema.transactions.find({
      parent: parentId
      isPaidDirect: {$ne: true}
    },
    {
      sort: {'version.createdAt': 1}
    })


scope.findOldDebtCustomer = ->
  if customer = Template.currentData()
    transaction = Schema.transactions.find({owner: customer._id, parent:{$exists: false}}, {sort: {'version.createdAt': 1}})
    transactionCount = transaction.count(); count = 0
    transaction.map(
      (transaction) ->
        count += 1
        transaction.isLastTransaction = true if count is transactionCount
        transaction
    )
  else []

scope.findAllOrders = ()->
  if customer = Template.currentData()
    beforeDebtCash = (customer.initialAmount ? 0)
    orders = Schema.orders.find({
      buyer      : customer._id
      orderType  : Enums.getValue('OrderTypes', 'success')
      orderStatus: Enums.getValue('OrderStatus', 'finish')
    }).map(
      (item) ->
        item.transactions = scope.transactionFind(item._id).map(
          (transaction) ->
            transaction.hasDebitBegin = (beforeDebtCash ? 0) > 0
            transaction.sumBeforeBalance = beforeDebtCash + transaction.balanceBefore
            if transaction.isRoot
              transaction.receivable       = true if (balanceChange = item.finalPrice - item.depositCash) > 0
              transaction.balanceChange    = Math.abs(balanceChange)
              transaction.sumLatestBalance = transaction.sumBeforeBalance + balanceChange
            else
              transaction.sumLatestBalance = beforeDebtCash + transaction.balanceLatest
            transaction
        )
        item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
        item
    )

    returns = Schema.returns.find({
      owner       : customer._id
      returnType  : Enums.getValue('ReturnTypes', 'customer')
      returnStatus: Enums.getValue('ReturnStatus', 'success')
    }).map(
      (item) ->
        item.transactions = scope.transactionFind(item._id).map(
          (transaction) ->
            transaction.hasDebitBegin = beforeDebtCash > 0
            transaction.sumBeforeBalance = beforeDebtCash + transaction.balanceBefore
            if transaction.isRoot
              transaction.receivable       = true if (balanceChange = -item.finalPrice + item.depositCash) > 0
              transaction.balanceChange    = Math.abs(balanceChange)
              transaction.sumLatestBalance = transaction.sumBeforeBalance + balanceChange
            else
              transaction.sumLatestBalance = beforeDebtCash + transaction.balanceLatest

            transaction
        )
        item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
        item
    )

    dataSource = _.sortBy(orders.concat(returns), (item) -> item.successDate )

    classColor = false
    for item in dataSource
      item.classColor = classColor
      classColor = !classColor
    dataSource

  else []







scope.checkAllowUpdateOverview = (template) ->
  console.log template
  Session.set "customerManagementShowEditCommand",
    template.ui.$customerName.val() isnt template.data.name or
      template.ui.$customerPhone.val() isnt (template.data.profiles.phone ? '') or
      template.ui.$customerAddress.val() isnt (template.data.profiles.address ? '')

scope.editCustomer = (template) ->
  customer = template.data
  if customer and Session.get("customerManagementShowEditCommand")
    name    = template.ui.$customerName.val()
    phone   = template.ui.$customerPhone.val()
    address = template.ui.$customerAddress.val()

    return if name.replace("(", "").replace(")", "").trim().length < 2
    editOptions = Helpers.splitName(name)
    editOptions['profiles.phone'] = phone if phone.length > 0
    editOptions['profiles.address'] = address if address.length > 0

    console.log editOptions

    if editOptions.name.length > 0
      customerFound = Schema.customers.findOne {name: editOptions.name, parentMerchant: customer.parentMerchant}

    if editOptions.name.length is 0
      template.ui.$customerName.notify("Tên khách hàng không thể để trống.", {position: "right"})
    else if customerFound and customerFound._id isnt customer._id
      template.ui.$customerName.notify("Tên khách hàng đã tồn tại.", {position: "right"})
      template.ui.$customerName.val editOptions.name
      Session.set("customerManagementShowEditCommand", false)
    else
      Schema.customers.update customer._id, {$set: editOptions}, (error, result) -> if error then console.log error
      template.ui.$customerName.val editOptions.name
      Session.set("customerManagementShowEditCommand", false)



scope.checkAllowCreateAndCreateTransaction = (event, template) ->
  if event.which is 13 then scope.createTransactionOfCustomer(event, template)
  else scope.checkAllowCreateTransactionOfCustomer(event, template)

scope.checkAllowCreateTransactionOfCustomer = (event, template) ->
  payAmount = parseInt($(template.find("[name='paySaleAmount']")).inputmask('unmaskedvalue'))
  if payAmount != 0 and !isNaN(payAmount)
    Session.set("allowCreateTransactionOfCustomer", true)
  else
    Session.set("allowCreateTransactionOfCustomer", false)

scope.createTransactionOfCustomer = (event, template) ->
  scope.checkAllowCreateTransactionOfCustomer(event, template)
  if Session.get("allowCreateTransactionOfCustomer")
    $payDescription = template.ui.$paySaleDescription
    $payAmount      = template.ui.$paySaleAmount
    payAmount       = parseInt($(template.find("[name='paySaleAmount']")).inputmask('unmaskedvalue'))
    description     = $payDescription.val()

    if !isNaN(payAmount) and payAmount != 0
      ownerId         = Template.currentData()._id
      debitCash       = Math.abs(payAmount)
      transactionType = Enums.getValue('TransactionTypes', 'saleCash')
      receivable      = false
      console.log debitCash
      Session.set("allowCreateTransactionOfCustomer", false)
      Session.set("customerManagementOldDebt")
      $payDescription.val(''); $payAmount.val('')
      console.log ownerId, debitCash, null, description, transactionType, receivable
      Meteor.call(
        'createNewTransaction'
        Enums.getValue('TransactionGroups', 'customer')
        transactionType
        receivable

        ownerId
        debitCash
        description
        (error, result) -> console.log error, result
      )



#----------------------------------------------------------------------------------------------

scope.CustomerSearchFindPreviousCustomer = (customerSearch) ->
  if previousRow = scope.customerLists.getPreviousBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': previousRow._id}})


scope.CustomerSearchFindNextCustomer = (customerSearch) ->
  if nextRow = scope.customerLists.getNextBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': nextRow._id}})


scope.customerManagementCreationMode = (textSearch = '')->
  if textSearch.length > 0
    if scope.customerLists.length is 0
      nameIsExisted = true
    else
      nameIsExisted = scope.customerLists[0].name.toLowerCase() isnt textSearch.toLowerCase()
    console.log nameIsExisted
  Session.set("customerManagementCreationMode", nameIsExisted)


scope.createNewCustomer = (template, customerSearch) ->
  newCustomer = Customer.splitName(customerSearch)

  if Customer.nameIsExisted(newCustomer.name, Session.get("myProfile").merchant)
    template.ui.$searchFilter.notify("Khách hàng đã tồn tại.", {position: "bottom"})
  else
    newCustomerId = Schema.customers.insert newCustomer
    if Match.test(newCustomerId, String)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': newCustomerId}})