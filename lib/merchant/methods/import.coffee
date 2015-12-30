Enums = Apps.Merchant.Enums


createTransaction = (provider, importData)->
  debitCash = (provider.interestAmount ? 0) + (provider.saleAmount ? 0) + (provider.loanAmount ? 0) + (provider.returnPaidAmount ? 0)
  paidCash  = (provider.returnAmount ? 0) + (provider.paidAmount ? 0)

  createTransactionOfImport =
    name         : 'Phiếu Bán'
    balanceType  : Enums.getValue('TransactionTypes', 'importAmount')
    receivable   : true
    isRoot       : true
    owner        : provider._id
    parent       : importData._id
    isUseCode    : false
    isPaidDirect : false
    balanceBefore: debitCash - paidCash
    balanceChange: importData.finalPrice
    balanceLatest: debitCash - paidCash + importData.finalPrice


  if transactionImportId = Schema.transactions.insert(createTransactionOfImport)
    if importData.depositCash > 0 #co tra tien
      createTransactionOfDepositImport =
        name         : 'Phiếu Thu Tiền'
        description  : 'Thanh toán phiếu: ' + importData.importCode
        balanceType  : Enums.getValue('TransactionTypes', 'providerPaidAmount')
        receivable   : false
        isRoot       : false
        owner        : provider._id
        parent       : importData._id
        isUseCode    : true
        isPaidDirect : true
        balanceBefore: debitCash - paidCash + importData.finalPrice
        balanceChange: importData.depositCash
        balanceLatest: debitCash - paidCash + importData.finalPrice - importData.depositCash

      Schema.transactions.insert(createTransactionOfDepositImport)

    providerUpdate =
      paidAmount   : importData.depositCash
      importAmount : importData.finalPrice

    Schema.providers.update importData.provider, { $inc: providerUpdate, $set: {allowDelete : false} }

  return transactionImportId





Meteor.methods
  providerToReturn: (providerId)->
    try
      user = Meteor.users.findOne(Meteor.userId())
      throw {valid: false, error: 'user not found!'} if !user

      provider = Schema.providers.findOne({_id: providerId, merchant: user.profile.merchant})
      throw {valid: false, error: 'provider not found!'} if !provider

      returnFound = Schema.returns.findOne({
        creator     : user._id
        owner       : provider._id
        returnType  : Enums.getValue('ReturnTypes', 'provider')
        returnStatus: Enums.getValue('ReturnStatus', 'initialize')
        merchant    : user.profile.merchant
      }, {sort: {'version.createdAt': -1}})

      if returnFound
        Return.setReturnSession(returnFound._id, 'provider')
      else
        returnType = Enums.getValue('ReturnTypes', 'provider')
        if returnId = Return.insert(returnType, provider._id)
          Return.setReturnSession(returnId, 'provider')

    catch error
      throw new Meteor.Error('providerToReturn', error)

  providerToImport: (providerId)->
    try
      user = Meteor.users.findOne(Meteor.userId())
      throw {valid: false, error: 'user not found!'} if !user

      provider = Schema.providers.findOne({_id: providerId, merchant: user.profile.merchant})
      throw {valid: false, error: 'provider not found!'} if !provider

      importFound = Schema.imports.findOne({
        creator   : user._id
        provider  : provider._id
        merchant  : user.profile.merchant
        importType: Enums.getValue('ImportTypes', 'initialize')
      }, {sort: {'version.createdAt': -1}})

      if importFound
        Import.setSession(importFound._id)
      else
        Import.setSession(importId) if importId = Import.insert(provider._id, provider.name)

    catch error
      throw new Meteor.Error('providerToImport', error)

  deleteImport: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user
    return {valid: false, error: 'user not permission!'} unless User.hasManagerRoles()

    query =
      seller     : user._id
      provider   : $exists: true
      merchant   : user.profile.merchant
      importType : Enums.getValue('ImportTypes', 'success')

    currentImportQuery = _.clone(query)
    currentImportQuery._id = importId

    currentImportFound = Schema.imports.findOne(currentImportQuery)
    return {valid: false, error: 'import not found!'} unless currentImportFound
    return {valid: false, error: 'import not delete!'} unless currentImportFound.allowDelete

    providerFound = Schema.providers.findOne(currentImportFound.provider)
    return {valid: false, error: 'provider not found!'} unless providerFound

    merchantFound = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchantFound


  importAccountingConfirmed: (importId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id         : importId
      merchant    : user.profile.merchant
      importType  : Enums.getValue('ImportTypes', 'staffConfirmed')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    providerFound = Schema.providers.findOne(importFound.provider)
    return {valid: false, error: 'provider not found!'} if !providerFound

    transactionId = createTransaction(providerFound, importFound)
    return {valid: false, error: 'customer not found!'} unless transactionId

    importUpdate = $set:
      importType         : Enums.getValue('ImportTypes', 'confirmedWaiting')
      accounting         : user._id
      accountingConfirm  : true
      accountingConfirmAt: new Date()
      transaction        : transactionId
    Schema.imports.update importFound._id, importUpdate


  importWarehouseConfirmed: (importId)->
    user = Meteor.users.findOne({_id: Meteor.userId()})
    return {valid: false, error: 'user not found!'} if !user

    importQuery =
      _id        : importId
      creator    : user._id
      merchant   : user.profile.merchant
      importType : Enums.getValue('ImportTypes', 'confirmedWaiting')
    importFound = Schema.imports.findOne importQuery
    return {valid: false, error: 'import not found!'} if !importFound

    providerFound = Schema.providers.findOne({_id: importFound.provider})
    return {valid: false, error: 'provider not found!'} if !providerFound

    merchantFound = Schema.merchants.findOne({_id: user.profile?.merchant})
    return {valid: false, error: 'merchant not found!'} if !merchantFound

    for productId in _.uniq(_.pluck(importFound.details, 'product'))
      productFound = Schema.products.findOne({_id: productId})
      return {valid: false, error: 'product not found!'} if !productFound

    #update quantity of product
    for detail, detailIndex in importFound.details
      updateQuery =
        $inc:
          'merchantQuantities.0.availableQuantity' : detail.basicQuantity
          'merchantQuantities.0.inStockQuantity'   : detail.basicQuantity
          'merchantQuantities.0.importQuantity'    : detail.basicQuantity
      if detail.expire
        updateQuery.$set = lastExpire: detail.expire
      Schema.products.update detail.product, updateQuery


    #update import
    providerCode  = Helpers.orderCodeCreate(providerFound.importBillNo)
    merchantCode = Helpers.orderCodeCreate(merchantFound.importBillNo)
    importUpdate =
      $set:
        importType : Enums.getValue('ImportTypes', 'success')
        successDate: new Date()
        importCode : providerCode + '/' + merchantCode
    Schema.imports.update importFound._id, importUpdate

    #update importBillNo of merchant
    merchantUpdate =
      $inc:
        importBill  : 1
        importBillNo: 1
    Schema.merchants.update merchantFound._id, merchantUpdate

    #update billNo of provider
    providerUpdate =
      $inc:
        billNo      : 1
        importBillNo: 1
    if providerFound.allowDelete
      providerUpdate.$set = allowDelete: false
    Schema.providers.update importFound.provider, providerUpdate
