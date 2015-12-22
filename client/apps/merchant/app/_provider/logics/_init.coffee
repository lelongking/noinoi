Enums = Apps.Merchant.Enums
logics.providerManagement = {} unless logics.providerManagement
scope = logics.providerManagement


scope.resetShowEditCommand = ->
  Session.set "providerManagementShowEditCommand"

scope.transactionFind = (parentId)->
  Schema.transactions.find({parent: parentId}, {sort: {'version.createdAt': 1}})

scope.findOldDebt = ->
  if providerId = Session.get("providerManagementProviderId")
    transaction = Schema.transactions.find({owner: providerId, parent:{$exists: false}}, {sort: {'version.createdAt': 1}})
    transactionCount = transaction.count(); count = 0
    transaction.map(
      (transaction) ->
        count += 1
        transaction.isLastTransaction = true if count is transactionCount
        transaction
    )
  else []

scope.findAllImport = ->
  if providerId = Session.get("providerManagementProviderId")
    imports = Schema.imports.find({
      provider  : providerId
      importType: Enums.getValue('ImportTypes', 'success')
    }).map(
      (item) ->
        item.transactions = scope.transactionFind(item._id).fetch()
        item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
        item
    )

    returns = Schema.returns.find({
      owner       : providerId
      returnType  : Enums.getValue('ReturnTypes', 'provider')
      returnStatus: Enums.getValue('ReturnStatus', 'success')
    }).map(
      (item) ->
        item.transactions = scope.transactionFind(item._id).fetch()
        item.transactions[item.transactions.length-1].isLastTransaction = true if item.transactions.length > 0
        item
    )

    dataSource = _.sortBy(imports.concat(returns), (item) -> item.successDate)
    classColor = false
    for item in dataSource
      item.classColor = classColor
      classColor = !classColor
    dataSource

  else []

scope.providerManagementCreationMode = () ->
  if Session.get("providerManagementSearchFilter").length > 0
    if scope.providerLists.length is 0 then nameIsExisted = true
    else if scope.providerLists.length is 1
      nameIsExisted = scope.providerLists[0].name isnt Session.get("providerManagementSearchFilter")
  Session.set("providerManagementCreationMode", nameIsExisted)


scope.ProviderSearchFindPreviousProvider = () ->
scope.ProviderSearchFindNextProvider = () ->



#-----------------Edit Provider-----------------------------------
scope.searchOrCreateProviderByInput = (event, template)->
  Helpers.deferredAction ->
    searchFilter  = template.ui.$searchFilter.val()
    providerSearch = Helpers.Searchify searchFilter
    Session.set("providerManagementSearchFilter", searchFilter)

    if event.which is 17 then console.log 'up'
#        else if event.which is 38 then scope.ProviderSearchFindPreviousProvider(providerSearch)
#        else if event.which is 40 then scope.ProviderSearchFindNextProvider(providerSearch)
    else
      if User.hasManagerRoles()
        scope.createNewProvider(template, providerSearch) if event.which is 13
        scope.providerManagementCreationMode(providerSearch)
      else
        Session.set("providerManagementCreationMode", false)

  , "providerManagementSearchPeople"
  , 50

scope.createProviderByBtn = (event, template)->
  fullText      = Session.get("providerManagementSearchFilter")
  providerSearch = Helpers.Searchify(fullText)
  scope.createNewProvider(template, providerSearch)
  ProviderSearch.search providerSearch

scope.createNewProvider = (template, providerSearch) ->
  fullText    = Session.get("providerManagementSearchFilter")
  newProvider = Provider.splitName(fullText)

  if Provider.nameIsExisted(newProvider.name, Session.get("myProfile").merchant)
    template.ui.$searchFilter.notify("Khách hàng đã tồn tại.", {position: "bottom"})
  else
    newProviderId = Schema.providers.insert newProvider
    if Match.test(newProviderId, String)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProvider': newProviderId}})

scope.editProvider = (template) ->
  provider = Session.get("providerManagementCurrentProvider")
  if provider and Session.get("providerManagementShowEditCommand")
    name  = template.ui.$providerName.val()
    phone = template.ui.$providerPhone.val()
    address = template.ui.$providerAddress.val()

    editOptions = {}
    editOptions.phone = phone if phone.length > 0
    editOptions.address = address if address.length > 0
    if name.length > 0
      editOptions.name = name
      providerFound = Schema.providers.findOne {name: name, parentMerchant: provider.parentMerchant}

    if name.length is 0
      template.ui.$providerName.notify("Tên nhà phân phối không thể để trống.", {position: "right"})
    else if providerFound and providerFound._id isnt provider._id
      template.ui.$providerName.notify("Tên nhà phân phối đã tồn tại.", {position: "right"})
      template.ui.$providerName.val name
      Session.set("providerManagementShowEditCommand", false)
    else
      Schema.providers.update provider._id, {$set: editOptions}, (error, result) -> if error then console.log error
      template.ui.$providerName.val editOptions.name
      Session.set("providerManagementShowEditCommand", false)

scope.checkAllowUpdateProviderOverview = (template) ->
  Session.set "providerManagementShowEditCommand",
    template.ui.$providerName.val() isnt Session.get("providerManagementCurrentProvider").name or
      template.ui.$providerPhone.val() isnt (Session.get("providerManagementCurrentProvider").phone ? '') or
      template.ui.$providerAddress.val() isnt (Session.get("providerManagementCurrentProvider").address ? '')


#-----------------Create Transaction-----------------------------------
scope.checkAllowCreateAndCreateTransaction = (event, template) ->
  if event.which is 13 then scope.createTransactionOfProvider(event, template)
  else scope.checkAllowCreateTransactionOfProvider(event, template)

scope.checkAllowCreateTransactionOfProvider = (event, template) ->
  payAmount = parseInt($(template.find("[name='payImportAmount']")).inputmask('unmaskedvalue'))
  if payAmount != 0 and !isNaN(payAmount)
    Session.set("allowCreateTransactionOfImport", true)
  else
    Session.set("allowCreateTransactionOfImport", false)

scope.createTransactionOfProvider= (event, template) ->
  scope.checkAllowCreateTransactionOfProvider(event, template)
  if Session.get("allowCreateTransactionOfImport")
    $payDescription = template.ui.$payImportDescription
    $payAmount      = template.ui.$payImportAmount
    payAmount       = parseInt($(template.find("[name='payImportAmount']")).inputmask('unmaskedvalue'))
    description     = $payDescription.val()

    if !isNaN(payAmount) and payAmount != 0
      ownerId         = scope.currentProvider._id
      debitCash       = Math.abs(payAmount)
      transactionType = Enums.getValue('TransactionTypes', 'provider')
      receivable      = Session.get("providerManagementOldDebt")
      Meteor.call 'createTransaction', ownerId, debitCash, null, description, transactionType, receivable, (error, result) ->
        Session.set("allowCreateTransactionOfImport", false)
        Session.set("providerManagementOldDebt")
        $payDescription.val(''); $payAmount.val('')
