Enums = Apps.Merchant.Enums
quantityHistory = new SimpleSchema
  merchantId    : type: String
  parent        : type: String
  parentType    : type: String
  code          : type: String
  method        : type: String
  createdAt     : type: Date
  price         : type: Number
  quantity      : type: Number
  finalQuantity : type: Number


merchantQuantity = new SimpleSchema
  merchantId            : type: String
  lowNormsQuantity      : type: Number, defaultValue: 0
  highNormsQuantity     : type: Number, defaultValue: 999999

  availableQuantity     : type: Number, defaultValue: 0
  orderQuantity         : type: Number, defaultValue: 0
  inStockQuantity       : type: Number, defaultValue: 0

  saleQuantity          : type: Number, defaultValue: 0
  returnSaleQuantity    : type: Number, defaultValue: 0
  importQuantity        : type: Number, defaultValue: 0
  returnImportQuantity  : type: Number, defaultValue: 0

  totalSaleQuantity          : type: Number, defaultValue: 0
  totalReturnSaleQuantity    : type: Number, defaultValue: 0
  totalImportQuantity        : type: Number, defaultValue: 0
  totalReturnImportQuantity  : type: Number, defaultValue: 0

productPriceBook = new SimpleSchema
  _id            : type: String
  basicSale      : type: Number, optional: true
  salePrice      : type: Number, optional: true
  basicSaleDebt  : type: Number, optional: true
  saleDebtPrice  : type: Number, optional: true
  basicImport    : type: Number, optional: true
  importPrice    : type: Number, optional: true

productUnit = new SimpleSchema
  _id         : type: String
  barcode     : simpleSchema.Barcode
  name        : type: String
  conversion  : type: Number
  isBase      : type: Boolean, defaultValue: false
  allowDelete : type: Boolean, defaultValue: true
  lastExpire  : type: Date   , optional: true
  createdAt   : simpleSchema.DefaultCreatedAt


#----------------------------------------------------------------------------------------------------------------------
simpleSchema.products = new SimpleSchema
  name    : type: String , index: 1
  code    : type: String , index: 1
  avatar  : type: String , optional: true
  status  : type: Number , defaultValue: Enums.getValue('ProductStatuses', 'initialize')

  inventoryInitial: type: Boolean , defaultValue: false
  interestRate    : type: Boolean , defaultValue: false #tinh lai suat
  description     : type: String  , optional: true
  lastExpire      : type: Date    , optional: true
  productOfGroup  : type: String  , optional: true
  importInventory : type: Number  , optional: true

  units      : type: [productUnit]     , defaultValue: []
  priceBooks : type: [productPriceBook], defaultValue: []

  merchantQuantities : type: [merchantQuantity], defaultValue: []
  quantityHistories  : type: [quantityHistory], defaultValue: []

  nameSearch  : simpleSchema.searchSource('name')
  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator('creator')
  version     : {type: simpleSchema.Version}





findPrice = (priceBookId, priceBookList, priceType = 'sale') ->
  if priceType is 'sale'
    for priceBook in priceBookList
      return priceBook.salePrice if priceBook._id is priceBookId
    return undefined

  else if priceType is 'import'
    for priceBook in priceBookList
      return priceBook.importPrice if priceBook._id is priceBookId
    return undefined

Schema.add 'products', "Product", class Product
  @transform: (doc) ->
    doc.hasAvatar   = -> if doc.avatar then '' else 'missing'
    doc.avatarUrl   = -> if doc.avatar then AvatarImages.findOne(doc.avatar)?.url() else undefined

    if doc.units?.length > 0
      doc.unitName    = -> doc.units[0].name
      doc.basicUnit   = -> doc.units[0]
      doc.basicUnitId = -> doc.units[0]._id

    if doc.merchantQuantities?.length > 0
      doc.allQuantity       = doc.merchantQuantities[0].inStockQuantity
      doc.saleQuantity      = doc.merchantQuantities[0].saleQuantity
      doc.saleReturnQuantity= doc.merchantQuantities[0].returnSaleQuantity
      doc.normsQuantity     = doc.merchantQuantities[0].lowNormsQuantity
      doc.normsCount        = doc.merchantQuantities[0].lowNormsQuantity - doc.merchantQuantities[0].inStockQuantity


    doc.getPrice = (ownerId, priceType = 'sale') ->
      priceFound = undefined; merchantId = Merchant.getId()
      if ownerId is undefined
        if priceBookBasic = Schema.priceBooks.findOne({priceBookType: 0, merchant: merchantId})
          priceFound = findPrice(priceBookBasic._id, doc.priceBooks, priceType) ? 0

      else
        if priceType is 'sale'
          buyer = Schema.customers.findOne({_id: ownerId, merchant: merchantId})
          if buyer
            priceBookOfBuyer = PriceBook.findOneByUnitAndBuyer(buyer._id, merchantId)
            priceBookOfBuyerGroup = PriceBook.findOneByUnitAndBuyerGroup(buyer.group, merchantId)
            priceFound = findPrice(priceBookOfBuyer._id, doc.priceBooks, priceType) if priceBookOfBuyer
            priceFound = findPrice(priceBookOfBuyerGroup._id, doc.priceBooks, priceType) if priceBookOfBuyerGroup and priceFound is undefined
          priceFound = findPrice(Session.get('priceBookBasic')._id, doc.priceBooks, priceType) if priceFound is undefined

        else if priceType is 'import'
          provider = Schema.providers.findOne({_id: ownerId, merchant: Session.get('merchant')._id})
          if provider
            priceBookOfProvider = PriceBook.findOneByUnitAndProvider(provider._id, merchantId)
            priceBookOfProviderGroup = PriceBook.findOneByUnitAndProviderGroup(provider.group, merchantId)
            priceFound = findPrice(priceBookOfProvider._id, doc.priceBooks, priceType) if priceBookOfProvider
            priceFound = findPrice(priceBookOfProviderGroup._id, doc.priceBooks, priceType) if priceBookOfProviderGroup and priceFound is undefined
          priceFound = findPrice(Session.get('priceBookBasic')._id, doc.priceBooks, priceType) if priceFound is undefined
      return priceFound

    doc.unitCreate = (name, conversion = 1)->
      unitNameIsExisted = false; conversion = Number(conversion)
      (unitNameIsExisted = true if unit.name is name) for unit in @units
      return if isNaN(conversion)

      unless unitNameIsExisted
        productUnit =
          _id         : Random.id()
          name        : name
          conversion  : conversion
          isBase      : false
          allowDelete : true

        Schema.products.update(@_id, {$push: { units: productUnit }})

    #cap nhat unit
    doc.unitUpdate = (unitId, option) ->
      unitNameIsNotExist = true
      barcodeIsNotExit   = true


      for instance, i in @units
        unitNameIsNotExist = false if option.name and instance.name is option.name
        (updateUnitIndex = i; updateInstance = instance; break) if instance._id is unitId


      if updateInstance
        unitUpdateQuery = $set:{}
        if option.name and unitNameIsNotExist
          unitUpdateQuery.$set["units.#{updateUnitIndex}.name"] = option.name


        if option.barcode and barcodeIsNotExit
          unitUpdateQuery.$set["units.#{updateUnitIndex}.barcode"] = option.barcode


        if option.conversion
          if updateInstance.allowDelete and updateInstance.isBase is false and option.conversion and option.conversion >= 1
            unitUpdateQuery.$set["units.#{updateUnitIndex}.conversion"] = option.conversion


        if updateInstance.isBase and option.importPrice and option.importPrice >= 0
          for priceBook, priceBookIndex in doc.priceBooks
            priceBookQuery = "priceBooks.#{priceBookIndex}"
            unitUpdateQuery.$set["#{priceBookQuery}.basicImport"] = option.importPrice
            unitUpdateQuery.$set["#{priceBookQuery}.importPrice"] = option.importPrice


        if updateInstance.isBase and option.salePrice and option.salePrice >= 0
          for priceBook, priceBookIndex in doc.priceBooks
            priceBookQuery = "priceBooks.#{priceBookIndex}"
            unitUpdateQuery.$set["#{priceBookQuery}.basicSale"] = option.salePrice
            unitUpdateQuery.$set["#{priceBookQuery}.salePrice"] = option.salePrice


        Schema.products.update(@_id, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)

    doc.unitDenyDelete = (unitId)->
      ((updateUnitIndex = index) if instance._id is unitId) for instance, index in @units
      unitUpdateQuery = $set:{}
      unitUpdateQuery.$set["units.#{updateUnitIndex}.allowDelete"] = false if updateUnitIndex
      Schema.products.update(@_id, unitUpdateQuery) unless _.isEmpty(unitUpdateQuery.$set)

    doc.unitRemove = (unitId, callback)->
      for instance, i in @units
        if instance._id is unitId
          removeIndex = i
          removeInstance = instance
          break

      if removeInstance and removeInstance.allowDelete and !removeInstance.isBase
        removeUnitQuery = { $pull:{ units: @units[removeIndex] } }
        if Schema.products.update(@_id, removeUnitQuery, callback) is 1
          PriceBook.reUpdateByRemoveProductUnit(removeInstance._id)

    doc.remove = (callback)->
      if @allowDelete
        if Schema.products.remove @_id, callback
          PriceBook.reUpdateByRemoveProduct(@_id)
          Schema.productGroups.update @group, $pull: {products: @_id }


    doc.productConfirm = ->
      if @status is Enums.getValue('ProductStatuses', 'initialize')
        Schema.products.update @_id, $set:{status: Enums.getValue('ProductStatuses', 'confirmed')}

    doc.submitInventory = (inventoryDetails)->
      if User.hasManagerRoles() and doc.inventoryInitial is false
        for detail in inventoryDetails
          if detail._id is doc.basicUnitId()
            importDetail = {_id: detail._id, quantity: detail.quality , expireDay: detail.expriceDay, product: doc._id}
            break

        console.log importDetail
        if importDetail
          Meteor.call 'productInventory', doc._id, importDetail, (error, result) -> console.log error, result

  @insert: (option = {unitBasicName: 'Chai'})->
    if priceBookBasic   = Schema.priceBooks.findOne({priceBookType: 0, merchant: Merchant.getId()})
      option.units      = generateUnit(Random.id(), option.unitBasicName)
      option.priceBooks = generatePriceBook(priceBookBasic._id)
      option.merchantQuantities = generateQuantity()
      option.quantityTurnover = generateTurnover()

      if newProductId = Schema.products.insert option
        Product.setSession(newProductId)
        PriceBook.addProduct(newProductId)
        ProductGroup.addProduct(newProductId)
      newProductId

  @nameIsExisted: (name, merchant = null) ->
    existedQuery = {name: name, merchant: merchant ? Meteor.user().profile.merchant}
    Schema.priceBooks.findOne(existedQuery)

  @setSession: (currentProductId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': currentProductId}})

generateQuantity = (warehouseId)->
  quantity = [{
    lowNormsQuantity     : 0
    availableQuantity    : 0
    inOderQuantity       : 0
    inStockQuantity      : 0
    saleQuantity         : 0
    importQuantity       : 0
    returnSaleQuantity   : 0
    returnImportQuantity : 0
  }]
  quantity.warehouseId = warehouseId if warehouseId
  quantity

generateTurnover = (warehouseId)->
  turnover = [{
    saleTurnover        : 0
    importTurnover      : 0
    returnSaleTurnover  : 0
    returnImportTurnover: 0
  }]
  turnover.warehouseId = warehouseId if warehouseId
  turnover


generatePriceBook = (priceBookBasicId)->
  [{ _id: priceBookBasicId, basicSale: 0, salePrice: 0, basicImport: 0, importPrice: 0 }]

generateUnit = (productUnitId, name = 'Chai', isBase = true, conversion = 1)->
  [{ _id: productUnitId, name: name, allowDelete: !isBase, isBase: isBase, conversion: conversion }]