addPriceInSmartUnit = (prices, smartUnitId, index, doc)->
  listPrices = _.where(prices, {unit: smartUnitId})
  branchPrice = _.findWhere(listPrices, {unit: smartUnitId}) #them id cua Branch
  basePrice   = _.findWhere(listPrices, {unit: smartUnitId})
  (currentPrice = branchPrice ? basePrice) if branchPrice or basePrice

  if currentPrice
    doc.smartUnits[index].priceId     = currentPrice._id
    doc.smartUnits[index].priceIndex  = _.indexOf(prices, currentPrice)
    doc.smartUnits[index].salePrice   = currentPrice.sale
    doc.smartUnits[index].importPrice = currentPrice.import

setBaseUnitAndPrice = (unit, index, doc)->
  doc.baseUnit     = unit._id
  doc.baseUnitName = unit.name
  doc.barcode      = unit.barcode
  doc.unitIndex    = index
  doc.priceIndex   = doc.smartUnits[index].priceIndex
  doc.salePrice    = doc.smartUnits[index].salePrice
  doc.importPrice  = doc.smartUnits[index].importPrice


Wings.Document.register 'products', 'Product', class Product
  @insert: (doc, callback) -> @document.insert doc, callback

  @transform: (doc) ->
    doc.generateUnit = (unitName, conversion = 1, isBase) ->
      _id        : Random.id()
      name       : unitName
      conversion : if isBase then 1 else conversion
      isBase     : isBase
      allowDelete: !isBase

    doc.generatePrice = (unitId, salePrice = 0, importPrice = 0, isBase) ->
      unit   : unitId
      sale   : salePrice
      import : importPrice
      isBase : isBase

    doc.searchPrice = (unitId) ->
      for price in @prices
        return price if price.unit is unitId
      return null

    doc.priceIsNotExist = (price) -> price >= 0 if price
    doc.unitNameIsNotExist = (unitName) ->
      return true if unit.name is unitName for unit in @units
      return false

    if doc.units?.length > 0
      doc.useAdvancePrice = true; doc.smartUnits = []
      for unit, index in doc.units
        doc.smartUnits.push(_.clone(unit))
        doc.smartUnits[index].unitIndex   = index
        doc.smartUnits[index].unitName    = doc.smartUnits[index].name
        doc.smartUnits[index].productName = doc.name

        addPriceInSmartUnit(doc.prices, unit._id, index, doc)
        setBaseUnitAndPrice(unit, index, doc) if unit.isBase

      doc.updateUnit = (option, callback) ->
        return unless typeof option is "object"
        ((unitIndex = i; break) if unit._id is option.id) for unit, i in @units
        ((priceIndex = i; break) if price.unit is option.id) for price, i in @prices if unitIndex >= 0

        updateUnitAndPrice = {$set:{}}
        if @unitNameIsNotExist(option.name)
          updateUnitAndPrice.$set["units."+unitIndex+".name"] = option.name
        if @priceIsNotExist(option.salePrice)
          updateUnitAndPrice.$set["prices."+priceIndex+".sale"] = option.salePrice
        if @priceIsNotExist(option.importPrice)
          updateUnitAndPrice.$set["prices."+priceIndex+".import"] = option.importPrice

        Document.Product.update(@_id, updateUnitAndPrice, callback) unless _.isEmpty(updateUnitAndPrice.$set)

      doc.removeUnit = (unitId, callback) ->
        return unless typeof unitId is "string"
        ((unitIndex = i; break) if unit._id is unitId) for unit, i in @units
        ((priceIndex = i; break) if price.unit is unitId) for price, i in @prices if unitIndex

        if @units[unitIndex].allowDelete
          removeUnitQuery = { $pull:{ units: @units[unitIndex], prices: @prices[priceIndex] } }
          Document.Product.update(@_id, removeUnitQuery, callback)

    doc.insertUnit = (option, callback) ->
      if @unitNameIsNotExist(option.name)
        isBase = if @units.length is 0 then true else false
        unit  = @generateUnit(option.name, option.conversion, isBase)
        price = @generatePrice(unit._id, option.salePrice, option.importPrice, isBase)
        Document.Product.update @_id, {$push: {units: unit, prices: price}}, callback

Document.Product.attachSchema new SimpleSchema
  name:
    type: String
    index: 1
    unique: true

  nameSearch: Schema.searchSource('name')

  description:
    type: String
    optional: true

  image:
    type: String
    optional: true

  imports:
    type: [String]
    optional: true

  sales:
    type: [String]
    optional: true

  returns:
    type: [String]
    optional: true

  creator   : Schema.creator
  slug      : Schema.slugify('Product')
  version   : { type: Schema.version }



  units: type: [Object], defaultValue: []
  'units.$._id'        : type: String
  'units.$.barcode'    : Schema.barcode
  'units.$.name'       : type: String
  'units.$.conversion' : type: Number
  'units.$.isBase'     : Schema.defaultBoolean()
  'units.$.allowDelete': Schema.defaultBoolean(true)
  'units.$.createdAt'  : Schema.defaultCreatedAt


  prices           : type: [Object], defaultValue: []
  'prices.$.branch': type: String  , optional: true
  'prices.$.unit'  : type: String
  'prices.$.isBase': Schema.defaultBoolean()
  'prices.$.sale'  : Schema.defaultNumber()
  'prices.$.import': Schema.defaultNumber()


  nameHistories:
    type: [Object]
    optional: true
    autoValue: ->
      unit = @field('units'); name = @field('name'); description = @field('description')
      if name.value and _.isEmpty(unit.value)
        return [{date: new Date, content: name.value, name: true}]
      else
        if !_.isEmpty(unit.value) and unit.value._id
          return {$push:{date: new Date, content: unit.value.name, unit: unit.value._id}}
        else if name.value
          return {$push : {date: new Date, content: name.value, name: true}}
        else
          @unset()
          return
  'nameHistories.$.name'        : type: Boolean, optional: true
  'nameHistories.$.unit'        : type: String , optional: true
  'nameHistories.$.date'        : type: Date   , optional: true
  'nameHistories.$.content'     : type: String , optional: true


  qualities                        : type: [Object], defaultValue: [{}]
  'qualities.$.branch'             : type: String  , optional: true
  'qualities.$.availableQuality'   : Schema.defaultNumber()
  'qualities.$.inOderQuality'      : Schema.defaultNumber()
  'qualities.$.inStockQuality'     : Schema.defaultNumber()
  'qualities.$.saleQuality'        : Schema.defaultNumber()
  'qualities.$.returnSaleQuality'  : Schema.defaultNumber()
  'qualities.$.importQuality'      : Schema.defaultNumber()
  'qualities.$.returnImportQuality': Schema.defaultNumber()