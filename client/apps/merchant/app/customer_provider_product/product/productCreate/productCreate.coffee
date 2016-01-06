numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:10, rightAlign: true}
numericOptionNotSuffix = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:3, rightAlign: true}
Enums = Apps.Merchant.Enums

Wings.defineHyper 'productCreate',
  created: ->
    self = this
    self.productUnitData = new ReactiveVar({
      isInventory: 'active'
      importQuality: 0
      unitName: 'Chai'
      directSalePrice: 0
      debtSalePrice: 0
      importPrice: 0

      unitNameEx: 'Thùng'
      barcode: Wings.Helper.GenerateBarcode()
      barcodeEx: Wings.Helper.GenerateBarcode()
      conversion: 24
      directSalePriceEx: 0
      debtSalePriceEx: 0
      importPriceEx: 0
      lowNorms: 0

    })

  rendered: ->
    @ui.$directSalePriceEx.inputmask "integer", numericOption
    @ui.$debtSalePriceEx.inputmask "integer", numericOption
    @ui.$importPriceEx.inputmask "integer", numericOption
    @ui.$directSalePrice.inputmask "integer", numericOption
    @ui.$debtSalePrice.inputmask "integer", numericOption
    @ui.$importPrice.inputmask "integer", numericOption
    @ui.$conversion.inputmask "integer", numericOptionNotSuffix
    @ui.$lowNorms.inputmask "integer", numericOptionNotSuffix
    @ui.$importQuality.inputmask "integer", {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: true}

    self = this
    productUnit = self.productUnitData.get()
    console.log productUnit
    self.ui.$directSalePriceEx.val productUnit.directSalePriceEx
    self.ui.$debtSalePriceEx.val productUnit.debtSalePriceEx
    self.ui.$importPriceEx.val productUnit.importPriceEx
    self.ui.$directSalePrice.val productUnit.directSalePrice
    self.ui.$debtSalePrice.val productUnit.debtSalePrice
    self.ui.$importPrice.val productUnit.importPrice
    self.ui.$conversion.val productUnit.conversion
    self.ui.$lowNorms.val productUnit.lowNorms

    self.ui.$barcode.val productUnit.barcode
    self.ui.$barcodeEx.val productUnit.barcodeEx


    self.ui.$productName.select()


  helpers:
    codeDefault: ->
      merchantSummaries = Session.get('merchant')?.summaries ? {}
      lastCode          = merchantSummaries.lastProductCode ? 0
      listProductCodes = merchantSummaries.listProductCodes ? []
      Wings.Helper.checkAndGenerateCode(lastCode, listProductCodes, 'SP')

    productUnit: ->
      Template.instance().productUnitData.get()

    productGroupSelected: -> productGroupSelect

  events:
    "click .cancelProduct": (event, template) ->
      currentRouter = FlowRouter.current()
      console.log FlowRouter.current()
      if currentRouter.oldRoute and currentRouter.oldRoute.name is 'order'
        FlowRouter.go('order')
      else
        FlowRouter.go('product')

    "click .addProduct": (event, template) ->
      addNewProduct(event, template)

    "blur [name='productName']": (event, template) ->
      checkProductName(event, template)

    "blur [name='productCode']": (event, template) ->
      checkProductCode(event, template)



    "keyup": (event, template) ->
      productUnitData = Template.instance().productUnitData
      productUnit = productUnitData.get()

      if event.target.name is "unitName"
        $unitName     = template.ui.$unitName
        unitNameText = $unitName.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if productUnit.unitName isnt unitNameText
          productUnit.unitName = unitNameText
          productUnitData.set(productUnit)

      else if event.target.name is "barcodeEx"
        $unitNameEx  = template.ui.$unitNameEx
        unitNameExText = $unitNameEx.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if productUnit.barcodeEx isnt unitNameExText
          productUnit.barcodeEx = unitNameExText
          productUnitData.set(productUnit)

      else if event.target.name is "barcode"
        $barcode  = template.ui.$barcode
        barcodeText = $barcode.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if productUnit.barcode isnt barcodeText
          productUnit.barcode = barcodeText
          productUnitData.set(productUnit)

      else if event.target.name is "barcodeEx"
        $unitNameEx  = template.ui.$unitNameEx
        unitNameExText = $unitNameEx.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if productUnit.barcodeEx isnt unitNameExText
          productUnit.barcodeEx = unitNameExText
          productUnitData.set(productUnit)

      else if event.target.name is "conversion"
        $conversion  = template.ui.$conversion
        conversionText = Math.abs(Helpers.Number($conversion.inputmask('unmaskedvalue')))

        if productUnit.conversion isnt conversionText
          productUnit.conversion = conversionText
          productUnit.directSalePriceEx = productUnit.directSalePrice * productUnit.conversion
          template.ui.$directSalePriceEx.val productUnit.directSalePriceEx
          productUnit.debtSalePriceEx = productUnit.debtSalePrice * productUnit.conversion
          template.ui.$debtSalePriceEx.val productUnit.debtSalePriceEx
          productUnit.importPriceEx = productUnit.importPrice * productUnit.conversion
          template.ui.$importPriceEx.val productUnit.importPriceEx
          productUnitData.set(productUnit)


      else if event.target.name is "directSalePrice"
        $directSalePrice  = template.ui.$directSalePrice
        directSalePriceText = Math.abs(Helpers.Number($directSalePrice.inputmask('unmaskedvalue')))

        if productUnit.directSalePrice isnt directSalePriceText
          productUnit.directSalePrice = directSalePriceText
          productUnit.directSalePriceEx = productUnit.directSalePrice * productUnit.conversion
          template.ui.$directSalePriceEx.val productUnit.directSalePriceEx
          productUnitData.set(productUnit)

      else if event.target.name is "debtSalePrice"
        $debtSalePrice  = template.ui.$debtSalePrice
        debtSalePriceText = Math.abs(Helpers.Number($debtSalePrice.inputmask('unmaskedvalue')))

        if productUnit.debtSalePrice isnt debtSalePriceText
          productUnit.debtSalePrice = debtSalePriceText
          productUnit.debtSalePriceEx = productUnit.debtSalePrice * productUnit.conversion
          template.ui.$debtSalePriceEx.val productUnit.debtSalePriceEx
          productUnitData.set(productUnit)

      else if event.target.name is "importPrice"
        $importPrice  = template.ui.$importPrice
        importPrice = Math.abs(Helpers.Number($importPrice.inputmask('unmaskedvalue')))

        if productUnit.importPrice isnt "importPrice"
          productUnit.importPrice = importPrice
          productUnit.importPriceEx = productUnit.importPrice * productUnit.conversion
          template.ui.$importPriceEx.val productUnit.importPriceEx
          productUnitData.set(productUnit)


      else if event.target.name is "directSalePriceEx"
        $debtSalePrice  = template.ui.$debtSalePrice
        directSalePriceEx = Math.abs(Helpers.Number($debtSalePrice.inputmask('unmaskedvalue')))

        if productUnit.directSalePriceEx isnt directSalePriceEx
          productUnit.directSalePriceEx = directSalePriceEx
          productUnitData.set(productUnit)

      else if event.target.name is "debtSalePriceEx"
        $debtSalePrice  = template.ui.$debtSalePrice
        debtSalePriceEx = Math.abs(Helpers.Number($debtSalePrice.inputmask('unmaskedvalue')))

        if productUnit.debtSalePriceEx isnt debtSalePriceEx
          productUnit.debtSalePriceEx = debtSalePriceEx
          productUnitData.set(productUnit)

      else if event.target.name is "importPriceEx"
        $debtSalePrice  = template.ui.$debtSalePrice
        importPriceEx = Math.abs(Helpers.Number($debtSalePrice.inputmask('unmaskedvalue')))

        if productUnit.importPriceEx isnt importPriceEx
          productUnit.importPriceEx = importPriceEx
          productUnitData.set(productUnit)


      else if event.target.name is "importQuality"
        $importQuality  = template.ui.$importQuality
        importQuality   = Math.abs(Helpers.Number($importQuality.inputmask('unmaskedvalue')))

        if productUnit.importQuality isnt importQuality
          productUnit.importQuality = importQuality
          productUnitData.set(productUnit)


      else if event.target.name is "lowNorms"
        $lowNorms  = template.ui.$lowNorms
        lowNorms = Math.abs(Helpers.Number($lowNorms.inputmask('unmaskedvalue')))

        if productUnit.lowNorms isnt lowNorms
          productUnit.lowNorms = lowNorms
          productUnitData.set(productUnit)



    "focus [name='importQuality']": (event, template) ->
      productUnit = Template.instance().productUnitData.get()
      productUnit.isInventory = ''
      Template.instance().productUnitData.set(productUnit)

    "blur [name='importQuality']": (event, template) ->
      productUnit = Template.instance().productUnitData.get()
      importQuality = template.ui.$importQuality.inputmask('unmaskedvalue')
      if importQuality is ''
        productUnit.isInventory = 'active'
      else
        absImportQuality = Math.abs(Helpers.Number(importQuality))
        template.ui.$importQuality.val absImportQuality
        productUnit.isInventory = ''
      Template.instance().productUnitData.set(productUnit)

    "click i.inventory": (event, template) ->
      productUnit   = Template.instance().productUnitData.get()
      if productUnit.isInventory is 'active'
        template.ui.$importQuality.val '0'
        template.ui.$importQuality.select()
      else
        template.ui.$importQuality.val ''
        template.ui.$importQuality.blur()


productGroupSelect =
  query: (query) -> query.callback
    results: Schema.productGroups.find(
      {$or: [{name: Helpers.BuildRegExp(query.term)}, {nameSearch: Helpers.BuildRegExp(query.term)}]}
    ,
      {sort: {nameSearch: 1, name: 1}}
    ).fetch()
    text: 'name'
  initSelection: (element, callback) -> callback Session.get("productCreateSelectedGroup") ? 'skyReset'
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'Chọn nhóm'
  changeAction: (e) -> Session.set("productCreateSelectedGroup", e.added)
  reactiveValueGetter: -> Session.get("productCreateSelectedGroup") ? 'skyReset'




checkProductName = (event, template, product) ->
  $productName = template.ui.$productName
  productName = $productName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if productName.length > 0
    $productName.removeClass('error')
    product.name = productName if product
  else
    $productName.addClass('error')
    $productName.notify('tên không được để trống', {position: "right"})
    return false

checkProductPhone = (event, template, product) ->
  $productPhone     = template.ui.$productPhone
  productPhone      = $productPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
  listProductPhones = Session.get('merchant')?.summaries?.listProductPhones ? []
  if productPhone.length > 0
    if _.indexOf(listProductPhones, $productPhone.val()) > -1
      $productPhone.addClass('error')
      $productPhone.notify('số điện thoại đã bị sử dụng', {position: "right"})
      return false
    else
      product.phone = productPhone if product
  else
    $productPhone.removeClass('error')
    $productPhone.val('')

checkProductCode = (event, template, product) ->
  $productCode     = template.ui.$productCode
  productCode      = $productCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  listProductCodes = Session.get('merchant')?.summaries?.listProductCodes ? []

  if productCode.length > 0
    if _.indexOf(listProductCodes, productCode) > -1
      $productCode.addClass('error')
      $productCode.notify('mã sản phẩm đã bị sử dụng', {position: "right"})
      return
    else
      product.code = productCode if product
  else
    $productCode.removeClass('error')
    $productCode.val('')

addNewProduct = (event, template, product = {}) ->
  merchantId      = Merchant.getId()
  productUnitData = Template.instance().productUnitData.get()
  priceBookBasic  = Schema.priceBooks.findOne({priceBookType: 0, merchant: Merchant.getId()})

  merchantSummaries = Session.get('merchant')?.summaries ? {}
  lastCode          = merchantSummaries.lastProductCode ? 0
  listProductCodes = merchantSummaries.listProductCodes ? []
  code = Wings.Helper.checkAndGenerateCode(lastCode, listProductCodes, 'SP')

  if checkProductName(event, template, product)
    if checkProductCode(event, template, product)
      product.code = code if !product.code
      $productDescription = template.ui.$productDescription
      productDescription  = $productDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
      product.description = productDescription if productDescription

      selectGroupId = Session.get("productCreateSelectedGroup")?._id
      product.productOfGroup = selectGroupId if selectGroupId

      product.status = Enums.getValue('ProductStatuses', 'confirmed')

      product.units = []

      unitName = if productUnitData.unitName.length > 0 then productUnitData.unitName else 'Chai'
      barcode  = if productUnitData.barcode.length > 0 then productUnitData.barcode else Wings.Helper.GenerateBarcode()
      productUnitBasic =
        _id        : Random.id()
        name       : unitName
        barcode    : barcode
        conversion : 1
        isBase     : true
      product.units.push productUnitBasic

      if productUnitData.conversion > 0
        unitNameEx = if productUnitData.unitNameEx.length > 0 then productUnitData.unitNameEx else 'Thùng'
        barcodeEx  = if productUnitData.barcodeEx.length > 0 then productUnitData.barcodeEx else Wings.Helper.GenerateBarcode()

        productUnitEx =
          _id             : Random.id()
          name            : unitNameEx
          barcode         : barcodeEx
          conversion      : productUnitData.conversion
          isBase          : false
        product.units.push productUnitEx

      product.priceBooks = [{
        _id           : priceBookBasic._id
        basicSale     : productUnitData.directSalePrice
        salePrice     : productUnitData.directSalePrice
        basicSaleDebt : productUnitData.debtSalePrice
        saleDebtPrice : productUnitData.debtSalePrice
        basicImport   : productUnitData.importPrice
        importPrice   : productUnitData.importPrice
      }]



      product.merchantQuantities = []
      merchantQuantity =
        merchantId       : merchantId
        lowNormsQuantity : productUnitData.lowNorms
      product.merchantQuantities.push merchantQuantity


      importQuality = parseInt(template.ui.$importQuality.inputmask('unmaskedvalue'))

      console.log product
      newProductId = Schema.products.insert product

      if Schema.products.findOne(newProductId)
        if importQuality isnt NaN
          importDetail = {quantity: importQuality, product: newProductId}
          Meteor.call 'productInventory', newProductId, importDetail, (error, result) -> console.log error, result


        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': newProductId}})

        currentRouter = FlowRouter.current()
        if currentRouter.oldRoute and currentRouter.oldRoute.name is 'order'
          FlowRouter.go('order')
        else
          FlowRouter.go('product')
        toastr["success"]("Tạo sản phẩm thành công.")

