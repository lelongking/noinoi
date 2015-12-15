numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:10, rightAlign: true}
numericOptionNotSuffix = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:3, rightAlign: true}

Wings.defineHyper 'productCreate',
  created: ->
    self = this
    self.productUnitData = new ReactiveVar({
      isInventory: 'active'
      unitName: 'Chai'
      directSalePrice: 0
      debtSalePrice: 0
      importPrice: 0

      unitNameEx: 'Thùng'
      barcode: ''
      barcodeEx: ''
      conversion: 0
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
    @ui.$conversion.inputmask "integer",
    @ui.$conversion.inputmask "integer", numericOptionNotSuffix
    @ui.$importQuality.inputmask "integer", {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: true}
    @ui.$lowNorms.inputmask "integer", numericOptionNotSuffix

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





  helpers:
    codeDefault: ->
      merchantSummaries = Session.get('merchant')?.summaries ? {}
      lastCode          = merchantSummaries.lastProductCode ? 0
      listProductCodes = merchantSummaries.listProductCodes ? []
      Wings.Helper.checkAndGenerateCode(lastCode, listProductCodes, 'SP')

    productUnit: ->
      Template.instance().productUnitData.get()

  events:
    "click .cancelProduct": (event, template) ->
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
  if checkProductName(event, template, product)
    if checkProductCode(event, template, product)
      newProductId = Schema.products.insert product
      if Match.test(newProductId, String)
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': newProductId}})
        FlowRouter.go('product')
        toastr["success"]("Tạo sản phẩm thành công.")

