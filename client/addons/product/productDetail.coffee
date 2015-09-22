Wings.defineWidget 'productDetail',
  rendered: -> "re-render!"
  destroyed: -> Session.set("showProductUnitCreatePane")

  events:
    "click .product-image": (event, template) -> template.find(".product-image-input").click()
    "change .product-image-input": (event, template) ->
      instance = @instance
      files = event.target.files
      if files.length > 0
        Storage.ProductImage.insert files[0], (error, fileObj) ->
          if error
            console.log 'avatar image upload error', error
          else
            Storage.ProductImage.findOne(instance.image)?.remove()
            Document.Product.update instance._id, $set: {image: fileObj._id}

    "click .product-image .clear": (event, template) ->
      Storage.ProductImage.findOne(@instance.image)?.remove()
      Document.Product.update @instance._id, $unset: {image: ""}
      event.stopPropagation()
#-------------------------------------------------------------------------
    "click .extract-unit": (event, template) ->
      $baseUnit = $(template.find(".baseUnitName"))
      $baseUnitInput = $(template.find(".baseUnitName input"))
      baseUnit = $baseUnitInput.val()
      if !template.data.instance.useAdvancePrice and !baseUnit
        $baseUnitInput.focus()
        Wings.SiderAlert.show $baseUnit, "Bạn phải <b>xác định đơn vị tính cơ bản</b> để thêm mới đơn vị tính <b>mở rộng</b>!", $baseUnitInput
      else
        Session.set("showProductUnitCreatePane", true)

    "click .save-price": (event, template) ->
      baseUnitName = $(template.find(".baseUnitName input")).val()
      salePrice    = accounting.parse $(template.find(".salePrice input")).val()
      importPrice  = accounting.parse $(template.find(".importPrice input")).val()

      baseUnit = {}
      baseUnit.name        = baseUnitName if @instance.baseUnitName isnt baseUnitName
      baseUnit.salePrice   = salePrice if @instance.salePrice isnt salePrice
      baseUnit.importPrice = importPrice if @instance.importPrice isnt importPrice

      if @instance.baseUnit
        baseUnit.id = @instance.baseUnit
        @instance.updateUnit baseUnit
      else
        @instance.insertUnit baseUnit

#-------------------------------------------------------------------------
    "click .cancel-add-unit": (event, template) -> Session.set("showProductUnitCreatePane")
    "wings-change .insertConversion": (event, template, value) ->
      $salePrice = $(template.find(".insertSalePrice input"))
      $salePrice.val(accounting.format(template.data.instance.salePrice * value))

    "click .add-unit": (event, template) ->
      $unitName        = $(template.find(".insertUnitName"))
      $unitNameInput   = $(template.find(".insertUnitName input"))
      $conversionInput = $(template.find(".insertConversion input"))
      $salePriceInput  = $(template.find(".insertSalePrice input"))

      newUnit = {}
      newUnit.name       = $unitNameInput.val()
      newUnit.conversion = accounting.parse $conversionInput.val()
      newUnit.salePrice  = accounting.parse $salePriceInput.val()

      if template.data.instance.unitNameIsNotExist(newUnit.name)
        template.data.instance.insertUnit(newUnit)
        Session.set('showProductUnitCreatePane')
      else
        $unitNameInput.focus()
        Wings.SiderAlert.show $unitName, "Tên của <b>đơn vị tính</b> bị trùng lắp!", $unitNameInput

#-------------------------------------------------------------------------
    "click .remove-unit": (event, template) -> template.data.instance.removeUnit @_id
    "click .update-unit": (event, template) ->
      $unitName        = $(template.find(".unitName"))
      $unitNameInput   = $(template.find(".unitName input"))
      $salePriceInput  = $(template.find(".salePrice input"))

      updateUnit = {id: @_id}
      updateUnit.name       = $unitNameInput.val()
      updateUnit.salePrice  = accounting.parse $salePriceInput.val()

      delete updateUnit.name if @name is updateUnit.name
      delete updateUnit.salePrice if @salePrice is updateUnit.salePrice

      return if _.keys(updateUnit).length < 2

      if unitFound = _.findWhere(template.data.instance.smartUnits, {_id: updateUnit.id})
        nameLists = _.pluck(template.data.instance.units, 'name')
        nameLists = _.without(nameLists, unitFound.name)

        if !$unitNameInput.val()
          $unitNameInput.focus()
          Wings.SiderAlert.show $unitName, "Tên của <b>đơn vị tính</b> không thể để trống!", $unitNameInput
        else if _.contains(nameLists, updateUnit.name)
          $unitNameInput.focus()
          Wings.SiderAlert.show $unitName, "Tên của <b>đơn vị tính</b> bị trùng lắp!", $unitNameInput
        else
          template.data.instance.updateUnit(updateUnit)


Wings.defineHyper 'productPriceBasic',
  helpers:
    unitLists: ->
      return [] unless @instance or @instance.baseUnit
      product = @instance
      _.reject(product.smartUnits, (num)-> num._id is product.baseUnit)
