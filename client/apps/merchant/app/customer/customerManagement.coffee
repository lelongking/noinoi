Enums = Apps.Merchant.Enums
scope = logics.customerManagement = {}

lemon.defineApp Template.customerManagement,
  created: ->
    Session.set("customerManagementSearchFilter", "")

    self = this
    self.ready = new ReactiveVar()
    self.autorun ()->
      if Session.get('mySession')
        scope.currentCustomer = Schema.customers.findOne(Session.get('mySession').currentCustomer)
        Session.set "customerManagementCurrentCustomer", scope.currentCustomer

        customerId = if scope.currentCustomer?._id then scope.currentCustomer._id else false
        if Session.get("customerManagementCustomerId") isnt customerId
          Session.set "customerManagementCustomerId", customerId


#      if self.appCount
#        handle = Wings.SubsManager.subscribe(self.appCount)
#        self.ready.set(handle.ready())

  rendered: ->


  helpers:
    creationMode: -> Session.get("customerManagementCreationMode")
    currentCustomer: -> Session.get("customerManagementCurrentCustomer")
    customerLists: ->
      selector = {}; options  = {sort: {nameSearch: 1}}; searchText = Session.get("customerManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {nameSearch: regExp}
        ]}

      if Session.get('myProfile')?.roles is 'seller'
        if(searchText)
          selector.$or[0]._id = $in: Session.get('myProfile').customers
        else
          selector = {_id: {$in: Session.get('myProfile').customers}}

      scope.customerLists = Schema.customers.find(selector, options).fetch()
      scope.customerLists


  events:
    # search customer and create customer if not search found
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        customerSearch = Helpers.Searchify searchFilter
        Session.set("customerManagementSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 38 then scope.CustomerSearchFindPreviousCustomer(customerSearch)
        else if event.which is 40 then scope.CustomerSearchFindNextCustomer(customerSearch)
        else
          if User.hasManagerRoles()
            scope.createNewCustomer(template, customerSearch) if event.which is 13
            setTimeout (-> scope.customerManagementCreationMode(customerSearch); return), 300
          else
            Session.set("customerManagementCreationMode", false)

      , "customerManagementSearchPeople"
      , 50

    "click .createCustomerBtn": (event, template) ->
      if User.hasManagerRoles()
        fullText      = Session.get("customerManagementSearchFilter")
        customerSearch = Helpers.Searchify(fullText)
        scope.createNewCustomer(template, customerSearch)
        CustomerSearch.search customerSearch

    "click .list .doc-item": (event, template) ->
      if userId = Meteor.userId()
#        Meteor.subscribe('customerManagementCurrentCustomerData', @_id)
        Meteor.users.update(userId, {$set: {'sessions.currentCustomer': @_id}})
        Session.set('customerManagementIsShowCustomerDetail', false)

#    "click .excel-customer": (event, template) -> $(".excelFileSource").click()
#    "change .excelFileSource": (event, template) ->
#      if event.target.files.length > 0
#        console.log 'importing'
#        $excelSource = $(".excelFileSource")
#        $excelSource.parse
#          config:
#            complete: (results, file) ->
#              console.log file, results
#              Apps.Merchant.importFileCustomerCSV(results.data)
#        $excelSource.val("")





scope.resetShowEditCommand = -> Session.set "customerManagementShowEditCommand"
scope.transactionFind = (parentId)-> Schema.transactions.find({parent: parentId}, {sort: {'version.createdAt': 1}})
scope.findOldDebtCustomer = ->
  if customerId = Session.get("customerManagementCustomerId")
    transaction = Schema.transactions.find({owner: customerId, parent:{$exists: false}}, {sort: {'version.createdAt': 1}})
    transactionCount = transaction.count(); count = 0
    transaction.map(
      (transaction) ->
        count += 1
        transaction.isLastTransaction = true if count is transactionCount
        transaction
    )
  else []

scope.findAllOrders = ->
  if customerId = Session.get("customerManagementCustomerId")
    orders = Schema.orders.find({
      buyer     : customerId
      orderType  : Enums.getValue('OrderTypes', 'success')
      orderStatus: Enums.getValue('OrderStatus', 'finish')
    }).map(
      (item) ->
        item.transactions = scope.transactionFind(item._id).fetch()
        item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
        item
    )

    returns = Schema.returns.find({
      owner       : customerId
      returnType  : Enums.getValue('ReturnTypes', 'customer')
      returnStatus: Enums.getValue('ReturnStatus', 'success')
    }).map(
      (item) ->
        item.transactions = scope.transactionFind(item._id).fetch()
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


scope.customerManagementCreationMode = (customerSearch)->
  textSearch = Session.get("customerManagementSearchFilter")
  if textSearch.length > 0
    if scope.customerLists.length is 0
      nameIsExisted = true
    else
      nameIsExisted = scope.customerLists[0].name.toLowerCase() isnt textSearch.toLowerCase()
    console.log nameIsExisted
  Session.set("customerManagementCreationMode", nameIsExisted)

scope.createNewCustomer = (template, customerSearch) ->
  fullText    = Session.get("customerManagementSearchFilter")
  newCustomer = Customer.splitName(fullText)

  if Customer.nameIsExisted(newCustomer.name, Session.get("myProfile").merchant)
    template.ui.$searchFilter.notify("Khách hàng đã tồn tại.", {position: "bottom"})
  else
    newCustomerId = Schema.customers.insert newCustomer
    if Match.test(newCustomerId, String)
      CustomerGroup.addCustomer(newCustomerId)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': newCustomerId}})

scope.CustomerSearchFindPreviousCustomer = (customerSearch) ->
  if previousRow = scope.customerLists.getPreviousBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': previousRow._id}})

scope.CustomerSearchFindNextCustomer = (customerSearch) ->
  if nextRow = scope.customerLists.getNextBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': nextRow._id}})

scope.checkAllowUpdateOverview = (template) ->
  Session.set "customerManagementShowEditCommand",
    template.ui.$customerName.val() isnt Session.get("customerManagementCurrentCustomer").name or
      template.ui.$customerPhone.val() isnt (Session.get("customerManagementCurrentCustomer").profiles.phone ? '') or
      template.ui.$customerAddress.val() isnt (Session.get("customerManagementCurrentCustomer").profiles.address ? '')

scope.editCustomer = (template) ->
  customer = Session.get("customerManagementCurrentCustomer")
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
      ownerId         = scope.currentCustomer._id
      debitCash       = Math.abs(payAmount)
      transactionType = Enums.getValue('TransactionTypes', 'customer')
      receivable      = Session.get("customerManagementOldDebt")
      console.log debitCash
      Session.set("allowCreateTransactionOfCustomer", false)
      Session.set("customerManagementOldDebt")
      $payDescription.val(''); $payAmount.val('')
      console.log ownerId, debitCash, null, description, transactionType, receivable
      Meteor.call 'createTransaction', ownerId, debitCash, null, description, transactionType, receivable, (error, result) ->
