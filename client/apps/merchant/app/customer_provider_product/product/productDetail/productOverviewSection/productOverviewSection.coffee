scope = {}
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:10, rightAlign: true}
numericOptionNotSuffix = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:3, rightAlign: true}
Wings.defineHyper 'productOverviewSection',
  created: ->
    currentData   = Template.currentData()
    productUnit   = currentData.units[0]
    productUnitEx = currentData.units[1]
    quantities    = currentData.merchantQuantities[0]
    priceBook     = currentData.priceBooks[0]

    console.log currentData
    console.log productUnit
    console.log productUnitEx

    self = this
    self.productUnitData = new ReactiveVar({
      isInventory: 'active'
      importQuality: currentData.importInventory ? 0
      lowNorms        : quantities.lowNormsQuantity

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
    })

  rendered: ->
    Session.set('productManagementIsShowProductDetail', false)
    Session.set("productManagementShowEditCommand", false)
    Session.set('productManagementIsEditMode', false)

    scope.overviewTemplateInstance = @
    @ui.$productName.autosizeInput({space: 10}) if @ui.$productName

    self = this
    productUnit = self.productUnitData.get()
    self.ui.$directSalePrice.inputmask "integer", numericOption
    self.ui.$debtSalePrice.inputmask "integer", numericOption
    self.ui.$importPrice.inputmask "integer", numericOption
    self.ui.$conversion.inputmask "integer", numericOptionNotSuffix
    self.ui.$lowNorms.inputmask "integer", numericOptionNotSuffix
    self.ui.$importQuality.inputmask "integer", {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:11, rightAlign: true}



    self.ui.$lowNorms.val productUnit.lowNorms
    self.ui.$barcode.val productUnit.barcode
    self.ui.$barcodeEx.val productUnit.barcodeEx

    self.ui.$directSalePrice.val productUnit.directSalePrice
    self.ui.$debtSalePrice.val productUnit.debtSalePrice
    self.ui.$importPrice.val productUnit.importPrice
    self.ui.$conversion.val productUnit.conversion


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

    productUnitDetail: ->
      Template.instance().productUnitData.get()

  events:
    "click .productDelete": (event, template) ->
      console.log 'is delete'
      #TODO: xoa khach hang

    "click .editProduct": (event, template) ->
      Session.set('productManagementIsShowProductDetail', true)
      Session.set('productManagementIsEditMode', true)

    "click .syncProductEdit": (event, template) ->
      editProduct(template)

    "click .cancelProduct": (event, template) ->
      Session.set('productManagementIsEditMode', false)



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
      checkAllowUpdateOverview(template)

    "keyup input.productEdit": (event, template) ->
      if event.which is 13 and template.data
        editProduct(template)
      else if event.which is 27 and template.data
        rollBackProductData(event, template)
      checkAllowUpdateOverview(template)


    "keyup": (event, template) ->
      productUnitData = Template.instance().productUnitData
      productUnit = productUnitData.get()

      if event.target.name is "unitName"
        $unitName     = template.ui.$unitName
        if event.which is 27
          $unitName.val productUnit.rollBackUnitName
        else
          unitNameText = $unitName.val().replace(/^\s*/, "").replace(/\s*$/, "")

          if productUnit.unitName isnt unitNameText
            productUnit.unitName = unitNameText
            productUnitData.set(productUnit)

      else if event.target.name is "barcodeEx"
        $unitNameEx  = template.ui.$unitNameEx
        if event.which is 27
          $unitNameEx.val productUnit.rollBackUnitNameEx
        else
          unitNameExText = $unitNameEx.val().replace(/^\s*/, "").replace(/\s*$/, "")

          if productUnit.barcodeEx isnt unitNameExText
            productUnit.barcodeEx = unitNameExText
            productUnitData.set(productUnit)

      else if event.target.name is "barcode"
        $barcode  = template.ui.$barcode
        if event.which is 27
          $barcode.val productUnit.rollBackBarcode
        else
          barcodeText = $barcode.val().replace(/^\s*/, "").replace(/\s*$/, "")

          if productUnit.barcode isnt barcodeText
            productUnit.barcode = barcodeText
            productUnitData.set(productUnit)

      else if event.target.name is "barcodeEx"
        $unitNameEx  = template.ui.$unitNameEx
        if event.which is 27
          $unitNameEx.val productUnit.rollBackUnitNameEx
        else
          unitNameExText = $unitNameEx.val().replace(/^\s*/, "").replace(/\s*$/, "")

          if productUnit.barcodeEx isnt unitNameExText
            productUnit.barcodeEx = unitNameExText
            productUnitData.set(productUnit)

      else if event.target.name is "conversion"
        $conversion  = template.ui.$conversion
        if event.which is 27
          $conversion.val productUnit.rollBackConversion
        else
          conversionText = Math.abs(Helpers.Number($conversion.inputmask('unmaskedvalue')))

          if productUnit.conversion isnt conversionText
            productUnit.conversion = conversionText
            productUnit.directSalePriceEx = productUnit.directSalePrice * productUnit.conversion
            productUnit.debtSalePriceEx = productUnit.debtSalePrice * productUnit.conversion
            productUnit.importPriceEx = productUnit.importPrice * productUnit.conversion
            productUnitData.set(productUnit)

      else if event.target.name is "directSalePrice"
        $directSalePrice  = template.ui.$directSalePrice
        if event.which is 27
          $directSalePrice.val productUnit.rollBackDirectSalePrice
        else
          directSalePriceText = Math.abs(Helpers.Number($directSalePrice.inputmask('unmaskedvalue')))

          if productUnit.directSalePrice isnt directSalePriceText
            productUnit.directSalePrice = directSalePriceText
            productUnit.directSalePriceEx = productUnit.directSalePrice * productUnit.conversion
            productUnitData.set(productUnit)

      else if event.target.name is "debtSalePrice"
        $debtSalePrice  = template.ui.$debtSalePrice
        if event.which is 27
          $debtSalePrice.val productUnit.rollBackDebtSalePrice
        else
          debtSalePriceText = Math.abs(Helpers.Number($debtSalePrice.inputmask('unmaskedvalue')))

          if productUnit.debtSalePrice isnt debtSalePriceText
            productUnit.debtSalePrice = debtSalePriceText
            productUnit.debtSalePriceEx = productUnit.debtSalePrice * productUnit.conversion
            productUnitData.set(productUnit)

      else if event.target.name is "importPrice"
        $importPrice  = template.ui.$importPrice
        if event.which is 27
          $importPrice.val productUnit.rollBackImportPrice
        else
          importPrice = Math.abs(Helpers.Number($importPrice.inputmask('unmaskedvalue')))
          if productUnit.importPrice isnt "importPrice"
            productUnit.importPrice = importPrice
            productUnit.importPriceEx = productUnit.importPrice * productUnit.conversion
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








#----------------------------------------------------------------------------------------------------------------------
checkAllowUpdateOverview = (template) ->
  productData        = template.data
  productName        = template.ui.$productName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productCode        = template.ui.$productCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productDescription = template.ui.$productDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")


  Session.set "productManagementShowEditCommand",
    productName isnt productData.name or
      productCode isnt (productData.code ? '') or
      productDescription isnt (productData.description ? '')


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
    name        = template.ui.$productName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    code        = template.ui.$productCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description = template.ui.$productDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
    listCodes   = summaries.listProductCodes ? []

    editOptions = {}
    editOptions.name        = name if name isnt product.name
    editOptions.code        = code if code isnt product.code
    editOptions.description = description if description isnt product.description


    console.log listCodes, editOptions.code, _.indexOf(listCodes, editOptions.code)
    if editOptions.name isnt undefined  and editOptions.name.length is 0
      template.ui.$productName.notify("Tên khách hàng không thể để trống.", {position: "right"})

    else if editOptions.code isnt undefined
      if editOptions.code.length > 0
        if listCodes.length > 0 and _.indexOf(listCodes, editOptions.code) isnt -1
          return template.ui.$productCode.notify("Mã khách hàng đã tồn tại.123123123", {position: "right"})
      else
        return template.ui.$productCode.notify("Mã khách hàng không thể để trống.", {position: "right"})

    else if editOptions.phone isnt undefined and listPhones.length > 0 and _.indexOf(listPhones, editOptions.phone) isnt -1
      return template.ui.$productPhone.notify("Số điện thoại đã tồn tại.", {position: "right"})


    if _.keys(editOptions).length > 0
      Schema.products.update product._id, {$set: editOptions}, (error, result) -> if error then console.log error
      Session.set("productManagementShowEditCommand", false)
      Session.set('productManagementIsEditMode', false)
      toastr["success"]("Cập nhật sản phẩm thành công.")



