recalculationImport = (importId) ->
  importFound = Document.Import.findOne(importId)
  totalPrice = 0
  (totalPrice += detail.quality * detail.price) for detail in importFound.details
  finalPrice = totalPrice - importFound.discountCash
  Document.Import.update importFound._id, $set:{totalPrice: totalPrice, finalPrice: finalPrice}

Wings.Document.register 'imports', 'Import', class Import
  @transform: (doc) ->
    doc.updateImport = (option, callback) ->
      return unless typeof option is "object"
      updateImport = {}
      if option.provider and option.provider isnt doc.provider
        updateImport.$set = {provider: option.provider}

      if option.description and option.description isnt doc.description
        updateImport.$set = {description: option.description}

      if option.discountCash and option.discountCash isnt doc.discountCash
        updateImport.$set = {discountCash: option.discountCash}

      if option.depositCash and option.depositCash isnt doc.depositCash
        updateImport.$set = {depositCash: option.depositCash}

      Document.Import.update doc._id, updateImport, callback

    doc.addDetail = (productUnitId, quality = 1, price, callback) ->
      return console.log('Khong tim thay Product') if !product = Document.Product.findOne({'units._id': productUnitId})
      return console.log('Khong tim thay ProductUnit') if !productUnit = _.findWhere(product.units, {_id: productUnitId})
      return console.log('Price not found..') if !price = price ? product.searchPrice(productUnitId)?.import
      return console.log("Price invalid (#{price})") if price < 0
      return console.log("Quality invalid (#{quality})") if quality < 1

      detailFindQuery = {product: product._id, productUnit: productUnitId, price: price}
      detailFound = _.findWhere(@details, detailFindQuery)
      console.log doc.details, detailFindQuery, detailFound

      if detailFound
        detailIndex = _.indexOf(@details, detailFound)
        updateQuery = {$inc:{}}
        updateQuery.$inc['details.'+detailIndex+'.quality'] = quality
        recalculationImport(@_id) if Document.Import.update(@_id, updateQuery, callback)

      else
        detailFindQuery.quality = quality
        recalculationImport(@_id) if Document.Import.update(@_id, { $push: {details: detailFindQuery} }, callback)

    doc.editDetail = (detailId, quality = null, price = null, callback)->
      return console.log('Import không tồn tại.') if (!self = Document.Import.findOne doc._id)

      detailFound = _.findWhere(self.details, {_id: detailId})
      return console.log('Thong tin detail sai') if !detailFound
      return console.log('Thong tin sai') if !quality or quality < 0 or !price  or price < 0

      detailIndex = _.indexOf(self.details, detailFound)
      updateDetail = {$set:{}}
      updateDetail.$set['details.'+detailIndex+'.quality'] = quality
      updateDetail.$set['details.'+detailIndex+'.price'] = price
      recalculationImport(self._id) if Document.Import.update(self._id, updateDetail, callback)

    doc.removeDetail = (detailId, callback)->
      return console.log('Import không tồn tại.') if (!self = Document.Import.findOne doc._id)
      return console.log('ImportDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationImport(self._id) if Document.Import.update(self._id, removeDetailQuery, callback)


    doc.submit = ->
      return console.log('Import không tồn tại.') if (!self = Document.Import.findOne doc._id)
      return console.log('Import đã Submit') if self.importType is Enum.importType.submitted
#      return console.log('Import chưa có Provider') if !self.provider

      for detail, detailIndex in self.details
        product = Document.Product.findOne({'units._id': detail.productUnit})
        return console.log('Khong tim thay Product') if !product
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        return console.log('Khong tim thay ProductUnit') if !productUnit
      Meteor.call 'importSubmit', self._id

Module "Enum",
  importType:
    created: 0
    submitted: 1


Document.Import.attachSchema new SimpleSchema
  importCode:
    type: String
    index: 1
    unique: true
    autoValue: -> return Random.id() if @isInsert

  branch:
    type: String
    optional: true

  provider:
    type: String
    optional: true

  importName:
    type: String
    defaultValue: "NHẬP KHO"

  description:
    type: String
    optional: true

  importType:
    type: Number
    defaultValue: Enum.importType.created

  sales:
    type: [String]
    optional: true

  returns:
    type: [String]
    optional: true

  discountCash: Schema.defaultNumber()
  depositCash : Schema.defaultNumber()
  totalPrice  : Schema.defaultNumber()
  finalPrice  : Schema.defaultNumber()
  slug        : Schema.clone('importCode')
  creator     : Schema.creator
  version     : { type: Schema.version }

  details: type: [Object], defaultValue: []
  'details.$._id'                : Schema.uniqueId
  'details.$.product'            : type: String
  'details.$.productUnit'        : type: String
  'details.$.quality'            : type: Number
  'details.$.price'              : type: Number
  'details.$.expire'             : type: Date, optional: true
  'details.$.availableQuality'   : Schema.defaultNumber()
  'details.$.inOderQuality'      : Schema.defaultNumber()
  'details.$.inStockQuality'     : Schema.defaultNumber()
  'details.$.saleQuality'        : Schema.defaultNumber()
  'details.$.returnSaleQuality'  : Schema.defaultNumber()
  'details.$.importQuality'      : Schema.defaultNumber()
  'details.$.returnImportQuality': Schema.defaultNumber()