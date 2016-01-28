scope = {}
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:10, rightAlign: true}
numericOptionNotSuffix = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:3, rightAlign: true}

Enums = Apps.Merchant.Enums
currentDataDefault = {}
Wings.defineHyper 'productOverviewSection',
  created: ->
    currentData     = Template.currentData()
    productUnitData = generateProductUnitData(currentData)
    self = this
    self.productUnitData = new ReactiveVar(productUnitData)

  rendered: ->
    Session.set('productManagementIsEditMode', false)
    Session.set('productManagementIsShowProductDetail', false)
    Session.set("productManagementShowEditCommand", false)


    scope.overviewTemplateInstance = @
    @ui.$productName.autosizeInput({space: 10}) if @ui.$productName

    self = this
    productUnit = self.productUnitData.get()
    console.log productUnit
    if self.ui.$directSalePrice
      self.ui.$directSalePrice.inputmask "integer", numericOption
      self.ui.$directSalePrice.val productUnit.directSalePrice

    if self.ui.$debtSalePrice
      self.ui.$debtSalePrice.inputmask "integer", numericOption
      self.ui.$debtSalePrice.val productUnit.debtSalePrice

    if self.ui.$debtSalePriceSub
      self.ui.$debtSalePriceSub.inputmask "integer", {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:10, rightAlign: false}
      self.ui.$debtSalePriceSub.val productUnit.debtSalePrice

    if self.ui.$importPrice
      self.ui.$importPrice.inputmask "integer", numericOption
      self.ui.$importPrice.val productUnit.importPrice

    if self.ui.$conversion
      self.ui.$conversion.inputmask "integer", numericOptionNotSuffix
      self.ui.$conversion.val productUnit.conversion

    if self.ui.$lowNorms
      self.ui.$lowNorms.inputmask "integer", numericOptionNotSuffix
      self.ui.$lowNorms.val productUnit.lowNorms

    if self.ui.$importQuality
      self.ui.$importQuality.inputmask "integer", {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: true}
      self.ui.$importQuality.val productUnit.inventoryQuality



    if self.ui.$barcode
      self.ui.$barcode.val productUnit.barcode

    if self.ui.$barcodeEx
      self.ui.$barcodeEx.val productUnit.barcodeEx







  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Session.equals("productManagementIsShowProductDetail", text) then '' else 'hidden'

    isEditMode: (text)->
      if Session.equals("productManagementIsEditMode", text) then '' else 'hidden'

    showSyncProduct: ->
      editCommand = Session.get("productManagementShowEditCommand")
      editMode = Session.get("productManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteProduct: ->
      editMode = Session.get("productManagementIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$productName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$productName?
      @name

    isShowInventory: (text)->
      instance    = Template.instance()
      currentData = instance.data
      if currentData.inventoryInitial is true
        if text then '' else 'hidden'
      else
        if Session.equals("productManagementIsEditMode", text) then 'hidden' else ''

    isShowConversion: (text)->
      instance        = Template.instance()
      currentData     = instance.data
      productUnitEx   = currentData.units[1]
      if text is productUnitEx.allowDelete then '' else 'hidden'

    productUnitDetail: ->
      instance        = Template.instance()
      currentData     = instance.data
      productUnitData = instance.productUnitData.get()

      if currentData._id isnt productUnitData.productId
        productUnitData = generateProductUnitData(currentData)
        instance.productUnitData.set(productUnitData)

        if instance.ui
          instance.ui.$lowNorms.val productUnitData.lowNorms
          instance.ui.$barcode.val productUnitData.barcode
          instance.ui.$barcodeEx.val productUnitData.barcodeEx

          instance.ui.$directSalePrice.val productUnitData.directSalePrice
          instance.ui.$debtSalePrice.val productUnitData.debtSalePrice
          instance.ui.$debtSalePriceSub.val productUnitData.debtSalePrice
          instance.ui.$importPrice.val productUnitData.importPrice
          instance.ui.$conversion.val productUnitData.conversion
          instance.ui.$importQuality.val productUnitData.inventoryQuality

      productUnitData

    productGroupSelected: -> productGroupSelects

    getPriceDebit: ->
      console.log @
      @getPrice(undefined, 'debit')

  events:
    "click .productDelete": (event, template) ->
      console.log 'is delete'
      #TODO: xoa khach hang

    "click .editProduct": (event, template) ->
      Session.set('productManagementIsShowProductDetail', true)
      Session.set('productManagementIsEditMode', true)
      productOverviewCheckAllowUpdate(template)

    "click .syncProductEdit": (event, template) ->
      editProduct(template)

    "click .cancelProduct": (event, template) ->
      Session.set('productManagementIsEditMode', false)
      instance        = Template.instance()
      productUnitData = generateProductUnitData(instance.data)
      instance.productUnitData.set(productUnitData)



#-------------------------------------------------------------------------------------------------
    "click span.hideTab": (event, template)->
      Session.set('productManagementIsShowProductDetail', false)

    "click span.showTab": (event, template)->
      Session.set('productManagementIsShowProductDetail', true)


#-------------------------------------------------------------------------------------------------
    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      updateChangeAvatar(event, template)

#-------------------------------------------------------------------------------------------------
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

#-------------------------------------------------------------------------------------------------
    'input input.productEdit': (event, template) ->
      productOverviewCheckAllowUpdate(template)

    "keyup input.productEdit": (event, template) ->
      if event.which is 13 and template.data
        editProduct(template)
      else if event.which is 27 and template.data
        rollBackProductData(event, template)
      productOverviewCheckAllowUpdate(template)


    "keyup": (event, template) ->
      productUnitData = Template.instance().productUnitData
      productUnit = productUnitData.get()

      if event.target.name is "unitName"
        $unitName    = template.ui.$unitName
        unitNameText = $unitName.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if event.which is 27
          unitNameText = productUnit.rollBackUnitName
          $unitName.val(unitNameText)

        if productUnit.unitName isnt unitNameText
          productUnit.unitName = unitNameText
          productUnitData.set(productUnit)

        $unitNameSub = template.ui.$unitNameSub
        $unitNameSub.val(unitNameText)


      else if event.target.name is "unitNameSub"
        $unitNameSub = template.ui.$unitNameSub
        unitNameText = $unitNameSub.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if event.which is 27
          unitNameText = productUnit.rollBackUnitName
          $unitNameSub.val(unitNameText)

        if productUnit.unitName isnt unitNameText
          productUnit.unitName = unitNameText
          productUnitData.set(productUnit)

        $unitName = template.ui.$unitName
        $unitName.val(unitNameText)


      else if event.target.name is "unitNameEx"
        $unitNameEx    = template.ui.$unitNameEx
        unitNameExText = $unitNameEx.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if event.which is 27
          productUnit.unitNameEx = productUnit.rollBackUnitNameEx
          $unitNameEx.val(productUnit.rollBackUnitNameEx)

        if productUnit.unitNameEx isnt unitNameExText
          productUnit.unitNameEx = unitNameExText
          productUnitData.set(productUnit)


      else if event.target.name is "barcode"
        $barcode    = template.ui.$barcode
        barcodeText = $barcode.val().replace(/^\s*/, "").replace(/\s*$/, "")
        if event.which is 27
          barcodeText = (productUnit.rollBackBarcode)
          $barcode.val productUnit.rollBackBarcode

        if productUnit.barcode isnt barcodeText
          productUnit.barcode = barcodeText
          productUnitData.set(productUnit)


      else if event.target.name is "barcodeEx"
        $barcodeEx    = template.ui.$barcodeEx
        barcodeExText = $unitNameEx.val().replace(/^\s*/, "").replace(/\s*$/, "")

        if event.which is 27
          barcodeExText = productUnit.rollBackBarcodeEx
          $barcodeEx.val productUnit.rollBackBarcodeEx

        if productUnit.barcodeEx isnt barcodeExText
          productUnit.barcodeEx = barcodeExText
          productUnitData.set(productUnit)


      else if event.target.name is "conversion"
        $conversion    = template.ui.$conversion
        conversionText = Math.abs(Helpers.Number($conversion.inputmask('unmaskedvalue')))
        if event.which is 27
          conversionText = productUnit.rollBackConversion
          $conversion.val productUnit.rollBackConversion

        if productUnit.conversion isnt conversionText
          productUnit.conversion = conversionText
          productUnit.directSalePriceEx = productUnit.directSalePrice * productUnit.conversion
          productUnit.debtSalePriceEx = productUnit.debtSalePrice * productUnit.conversion
          productUnit.importPriceEx = productUnit.importPrice * productUnit.conversion
          productUnitData.set(productUnit)



      else if event.target.name is "directSalePrice"
        $directSalePrice    = template.ui.$directSalePrice
        directSalePriceText = Math.abs(Helpers.Number($directSalePrice.inputmask('unmaskedvalue')))

        if event.which is 27
          directSalePriceText = productUnit.rollBackDirectSalePrice
          $directSalePrice.val productUnit.rollBackDirectSalePrice

        if productUnit.directSalePrice isnt directSalePriceText
          productUnit.directSalePrice = directSalePriceText
          productUnit.directSalePriceEx = productUnit.directSalePrice * productUnit.conversion
          productUnitData.set(productUnit)



      else if event.target.name is "debtSalePrice"
        $debtSalePrice  = template.ui.$debtSalePrice
        debtSalePriceText = Math.abs(Helpers.Number($debtSalePrice.inputmask('unmaskedvalue')))

        if event.which is 27
          debtSalePriceText = productUnit.rollBackDebtSalePrice
          $debtSalePrice.val debtSalePriceText

        if productUnit.debtSalePrice isnt debtSalePriceText
          productUnit.debtSalePrice = debtSalePriceText
          productUnit.debtSalePriceEx = productUnit.debtSalePrice * productUnit.conversion
          productUnitData.set(productUnit)

        $debtSalePriceSub  = template.ui.$debtSalePriceSub
        $debtSalePriceSub.val debtSalePriceText


      else if event.target.name is "debtSalePriceSub"
        $debtSalePriceSub  = template.ui.$debtSalePriceSub
        debtSalePriceText = Math.abs(Helpers.Number($debtSalePriceSub.inputmask('unmaskedvalue')))

        if event.which is 27
          debtSalePriceText = productUnit.rollBackDebtSalePrice
          $debtSalePriceSub.val debtSalePriceText

        if productUnit.debtSalePrice isnt debtSalePriceText
          productUnit.debtSalePrice = debtSalePriceText
          productUnit.debtSalePriceEx = productUnit.debtSalePrice * productUnit.conversion
          productUnitData.set(productUnit)

        $debtSalePrice  = template.ui.$debtSalePrice
        $debtSalePrice.val debtSalePriceText


      else if event.target.name is "importPrice"
        $importPrice  = template.ui.$importPrice
        importPrice   = Math.abs(Helpers.Number($importPrice.inputmask('unmaskedvalue')))

        if event.which is 27
          importPrice = productUnit.rollBackImportPrice
          $importPrice.val productUnit.rollBackImportPrice

        if productUnit.importPrice isnt importPrice
          productUnit.importPrice = importPrice
          productUnit.importPriceEx = productUnit.importPrice * productUnit.conversion
          productUnitData.set(productUnit)



      else if event.target.name is "importQuality"
        $importQuality  = template.ui.$importQuality
        importQuality   = Math.abs(Helpers.Number($importQuality.inputmask('unmaskedvalue')))

        if event.which is 27
          if productUnitData.isInventory is 'active'
            $importQuality.val ''
            productUnit.inventoryQuality = ''
          else
            importQuality = productUnit.rollImportQuality
            $importQuality.val importQuality
            productUnit.inventoryQuality = importQuality


        if productUnit.inventoryQuality isnt importQuality
          productUnit.inventoryQuality = importQuality
          productUnitData.set(productUnit)
          Session.set "productManagementShowEditCommand", true

      else if event.target.name is "lowNorms"
        $lowNorms = template.ui.$lowNorms
        lowNorms  = Math.abs(Helpers.Number($lowNorms.inputmask('unmaskedvalue')))

        if event.which is 27
          lowNorms = productUnit.rollLowNorms
          $lowNorms.val productUnit.rollLowNorms

        if productUnit.lowNorms isnt lowNorms
          productUnit.lowNorms = lowNorms
          productUnitData.set(productUnit)

      else if event.target.name is "productCode"
        productData  = template.data
        $productCode = template.ui.$productCode

        if event.which is 27
          $productCode.val productData.code

      else if event.target.name is "productDescription"
        productData         = template.data
        $productDescription = template.ui.$productDescription

        if event.which is 27
          $productDescription.val productData.description

      productOverviewCheckAllowUpdate(template)
      editProduct(template) if event.which is 13 and template.data



productGroupSelects =
  query: (query) -> query.callback
    results: Schema.productGroups.find(
      {$or: [{nameSearch: Helpers.BuildRegExp(query.term)}, {name: Helpers.BuildRegExp(query.term)}]}
    ,
      {sort: {nameSearch: 1, name: 1}}
    ).fetch()
    text: 'name'
  initSelection: (element, callback) -> callback Session.get("productManagementSelectedGroup") ? 'skyReset'
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'Chọn nhóm'
  changeAction: (e) ->
    Session.set("productManagementSelectedGroup", e.added)
    Session.set("productManagementShowEditCommand", true)
    productOverviewCheckAllowUpdate(template)
  reactiveValueGetter: -> Session.get("productManagementSelectedGroup") ? 'skyReset'



#----------------------------------------------------------------------------------------------------------------------

generateProductUnitData = (currentData)->
  productUnit   = currentData.units[0]
  productUnitEx = currentData.units[1] ? currentData.units[0]
  quantities    = currentData.merchantQuantities[0]
  priceBook     = currentData.priceBooks[0]

  productUnitData =
    productId       : currentData._id
    lowNorms        : quantities.lowNormsQuantity

    unitId          : productUnit._id
    unitExId        : productUnitEx._id
    unitName        : productUnit.name
    unitNameEx      : productUnitEx.name
    conversion      : productUnitEx.conversion
    barcode         : productUnit.barcode
    barcodeEx       : productUnitEx.barcode

    directSalePrice   : priceBook.basicSale
    debtSalePrice     : priceBook.basicSaleDebt
    importPrice       : priceBook.basicImport

    directSalePriceEx : priceBook.basicSale * productUnitEx.conversion
    debtSalePriceEx   : priceBook.basicSaleDebt * productUnitEx.conversion
    importPriceEx     : priceBook.basicImport * productUnitEx.conversion

    rollBackUnitName          : productUnit.name
    rollBackUnitNameEx        : productUnitEx.name
    rollBackConversion        : productUnitEx.conversion
    rollBackBarcode           : productUnit.barcode
    rollBackBarcodeEx         : productUnitEx.barcode
    rollBackDirectSalePrice   : priceBook.basicSale
    rollBackDebtSalePrice     : priceBook.basicSaleDebt
    rollBackImportPrice       : priceBook.basicImport
    rollLowNorms              : quantities.lowNormsQuantity
    rollImportQuality         : currentData.importInventory ? 0

  console.log currentData.inventoryInitial
  if currentData.inventoryInitial
    productUnitData.isInventory       = ''
    productUnitData.inventoryQuality  = currentData.importInventory ? 0
    productUnitData.importQuality     = accounting.formatNumber(currentData.importInventory ? 0) + ' ' + productUnitData.unitName
  else
    productUnitData.isInventory       = 'active'
    productUnitData.inventoryQuality  = ''
    productUnitData.importQuality     = 'Chưa nhập tồn kho đầu kỳ'

  productUnitData

productOverviewCheckAllowUpdate = (template) ->
  productData   = template.data
  productUnit   = productData.units[0]
  productUnitEx = productData.units[1] ? productData.units[0]
  priceBook     = productData.priceBooks[0]
  quantities    = productData.merchantQuantities[0]

  productName        = template.ui.$productName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productCode        = template.ui.$productCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productDescription = template.ui.$productDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

  productBarcode    = template.ui.$barcode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productBarcodeEx  = template.ui.$barcodeEx.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productUnitName   = template.ui.$unitName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productUnitNameEx = template.ui.$unitNameEx.val().replace(/^\s*/, "").replace(/\s*$/, "")

  productDirectSalePrice = parseInt(template.ui.$directSalePrice.inputmask('unmaskedvalue'))
  productDebtSalePrice = parseInt(template.ui.$debtSalePrice.inputmask('unmaskedvalue'))
  productImportPrice = parseInt(template.ui.$importPrice.inputmask('unmaskedvalue'))
  productConversion = parseInt(template.ui.$conversion.inputmask('unmaskedvalue'))
  inventoryQuality = parseInt(template.ui.$importQuality.inputmask('unmaskedvalue'))
  productLowNorms  =  parseInt(template.ui.$lowNorms.inputmask('unmaskedvalue'))
  productOfGroup   = Session.get("productManagementSelectedGroup")?._id






  Session.set "productManagementShowEditCommand",
    productName isnt productData.name or
      productCode isnt (productData.code ? '') or
      productDescription isnt (productData.description ? '') or


      productDirectSalePrice isnt (priceBook.basicSale ? '') or
      productDebtSalePrice isnt (priceBook.basicSaleDebt ? '') or
      productImportPrice isnt (priceBook.basicImport ? '') or
      productLowNorms isnt (quantities.lowNormsQuantity ? '') or
      (
        if productData.inventoryInitial
          inventoryQuality isnt (productData.importInventory ? '')
        else
          !isNaN(inventoryQuality)
      ) or

      productOfGroup isnt (productData.productOfGroup ? '') or
      productUnitName isnt (productUnit.name ? '') or
      productBarcode isnt (productUnit.barcode ? '') or
      productUnitNameEx isnt (productUnitEx.name ? '') or
      productBarcodeEx isnt (productUnitEx.barcode ? '') or
      productConversion isnt (productUnitEx.conversion ? '')



rollBackProductData = (event, template)->
  productData = template.data
  if $(event.currentTarget).attr('name') is 'productName'
    $(event.currentTarget).val(productData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'productCode'
    $(event.currentTarget).val(productData.code)
  else if $(event.currentTarget).attr('name') is 'productDescription'
    $(event.currentTarget).val(productData.description)

updateChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; product = Template.currentData()
    if files.length > 0 and product?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.products.update(product._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(product.avatar)?.remove()

editProduct = (template) ->
  product   = template.data
  summaries = Session.get('merchant')?.summaries
  if product and Session.get("productManagementShowEditCommand")
    name             = template.ui.$productName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    code             = template.ui.$productCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description      = template.ui.$productDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
    listCodes        = summaries.listProductCodes ? []
    productOfGroup   = Session.get("productManagementSelectedGroup")?._id


    editOptions = {}
    editOptions.name        = name if name isnt product.name
    editOptions.code        = code if code isnt product.code
    editOptions.description = description if description isnt product.description
    editOptions.productOfGroup = productOfGroup if productOfGroup isnt product.productOfGroup

    productLowNorms =  parseInt(template.ui.$lowNorms.inputmask('unmaskedvalue'))
    if !isNaN(productLowNorms) and productLowNorms isnt product.merchantQuantities[0].lowNormsQuantity
      editOptions['merchantQuantities[0].lowNormsQuantity'] = productLowNorms




    console.log listCodes, editOptions.code, _.indexOf(listCodes, editOptions.code)
    if editOptions.name isnt undefined  and editOptions.name.length is 0
      template.ui.$productName.notify("Tên khách hàng không thể để trống.", {position: "right"})

    else if editOptions.code isnt undefined
      if editOptions.code.length > 0
        if listCodes.length > 0 and _.indexOf(listCodes, editOptions.code) isnt -1
          return template.ui.$productCode.notify("Mã khách hàng đã tồn tại.", {position: "right"})
      else
        return template.ui.$productCode.notify("Mã khách hàng không thể để trống.", {position: "right"})

    else if editOptions.phone isnt undefined and listPhones.length > 0 and _.indexOf(listPhones, editOptions.phone) isnt -1
      return template.ui.$productPhone.notify("Số điện thoại đã tồn tại.", {position: "right"})


    if _.keys(editOptions).length > 0
      Schema.products.update product._id, {$set: editOptions}, (error, result) -> if error then console.log error



    if productFound = Schema.products.findOne({_id: product._id})
      productUnit = Template.instance().productUnitData.get()
      unitBase =
        _id           : productUnit.unitId
        name          : productUnit.unitName
        barcode       : productUnit.barcode
        importPrice   : productUnit.importPrice
        salePrice     : productUnit.directSalePrice
        saleDebtPrice : productUnit.debtSalePrice
      productFound.unitUpdate(unitBase._id, unitBase)

      unitEx =
        _id           : productUnit.unitExId
        name          : productUnit.unitNameEx
        barcode       : productUnit.barcodeEx
        conversion    : productUnit.conversion
      productFound.unitUpdate(unitEx._id, unitEx)


      importQuality = parseInt(template.ui.$importQuality.inputmask('unmaskedvalue'))
      if importQuality isnt NaN
        if productFound.inventoryInitial
          importFound = Schema.imports.findOne(
            'details.product': product._id
            importType       : Enums.getValue('ImportTypes', 'inventorySuccess')
          )
          if importFound and importQuality isnt importFound.details[0].basicQuantity
            importFound.editImportDetail(importFound.details[0]._id, importQuality)

            quantityChange = importQuality - product.importInventory
            productUpdate =
              $set:
                importInventory: importQuality
              $inc:
                'merchantQuantities.0.availableQuantity' : quantityChange
                'merchantQuantities.0.inStockQuantity'   : quantityChange
                'merchantQuantities.0.importQuantity'    : quantityChange
            Schema.products.update product._id, productUpdate

        else
          importDetail = {quantity: importQuality, product: product._id}
          Meteor.call 'productInventory', product._id, importDetail, (error, result) -> console.log error, result

      productUnitData = generateProductUnitData(Schema.products.findOne({_id: product._id}))
      Template.instance().productUnitData.set(productUnitData)
      productOverviewCheckAllowUpdate(template)

      Session.set("productManagementShowEditCommand", false)
      Session.set('productManagementIsEditMode', false)
      toastr["success"]("Cập nhật sản phẩm thành công.")