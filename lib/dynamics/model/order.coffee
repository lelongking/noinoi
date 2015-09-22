recalculationOrder = (orderId) ->
  importFound = Document.Order.findOne(orderId)
  totalPrice = 0
  (totalPrice += detail.quality * detail.price) for detail in importFound.details
  finalPrice = totalPrice - importFound.discountCash
  Document.Order.update importFound._id, $set:{totalPrice: totalPrice, finalPrice: finalPrice}

Wings.Document.register 'orders', 'Order', class Order
  @transform: (doc) ->
    doc.buyerInstance = -> Document.Customer.findOne(doc.buyer)

    doc.recalculatePrices = (newId, newQuality, newPrice) ->
      totalPrice = 0
      for detail in @details
        if detail._id is newId
          totalPrice += newQuality * newPrice
        else
          totalPrice += detail.quality * detail.price

      totalPrice: totalPrice
      finalPrice: totalPrice - @discountCash

    doc.updateOrder = (option, callback) ->
      return unless typeof option is "object"

      updateOrder = {}
      if option.buyer and option.buyer isnt doc.buyer
        updateOrder.$set = {buyer: option.buyer}

      if option.description and option.description isnt doc.description
        updateOrder.$set = {description: option.description}

      if option.orderType and option.orderType isnt doc.orderType
        updateOrder.$set = {orderType: option.orderType}

      if option.discountCash and option.discountCash isnt doc.discountCash
        updateOrder.$set = {discountCash: option.discountCash}

      if option.depositCash and option.depositCash isnt doc.depositCash
        updateOrder.$set = {depositCash: option.depositCash}

      Document.Order.update doc._id, updateOrder, callback

    doc.addDetail = (productUnitId, quality = 1, price, callback) ->
      return console.log('Khong tim thay Product') if !product = Document.Product.findOne({'units._id': productUnitId})
      return console.log('Khong tim thay ProductUnit') if !productUnit = _.findWhere(product.smartUnits, {_id: productUnitId})
      return console.log('Price not found..') if !price = price ? product.searchPrice(productUnitId)?.sale
      return console.log("Price invalid (#{price})") if price < 0
      return console.log("Quality invalid (#{quality})") if quality < 1

      detailFindQuery = {product: product._id, productUnit: productUnitId, price: price}
      detailFound = _.findWhere(@details, detailFindQuery)
      console.log doc.details, detailFindQuery, detailFound

      console.log productUnit.conversion
      if detailFound
        detailIndex = _.indexOf(@details, detailFound)
        updateQuery = {$inc:{}}
        updateQuery.$inc["details.#{detailIndex}.quality"] = quality
        updateQuery.$inc["details.#{detailIndex}.basicQuality"] = quality * productUnit.conversion
        recalculationOrder(@_id) if Document.Order.update(@_id, updateQuery, callback)

      else
        detailFindQuery.quality = quality
        detailFindQuery.basicQuality = quality * productUnit.conversion
        recalculationOrder(@_id) if Document.Order.update(@_id, { $push: {details: detailFindQuery} }, callback)

    doc.editDetail = (detailId, quality, price, callback) ->
      for instance, i in @details
        if instance._id is detailId
          updateIndex = i
          updateInstance = instance
          conversionUnit = updateInstance.basicQuality/updateInstance.quality
      return console.log 'OrderDetailRow not found..' if !updateInstance

      newSummary = @recalculatePrices(detailId, quality, price)

      predicate = $set:{}
      predicate.$set["totalPrice"] = newSummary.totalPrice
      predicate.$set["finalPrice"] = newSummary.finalPrice
      predicate.$set["details.#{updateIndex}.quality"] = quality
      predicate.$set["details.#{updateIndex}.basicQuality"] = quality * conversionUnit
      predicate.$set["details.#{updateIndex}.price"] = price
      Document.Order.update @_id, predicate, callback

    doc.removeDetail = (detailId, callback) ->
      return console.log('Order không tồn tại.') if (!self = Document.Order.findOne doc._id)
      return console.log('OrderDetail không tồn tại.') if (!detailFound = _.findWhere(self.details, {_id: detailId}))
      detailIndex = _.indexOf(self.details, detailFound)
      removeDetailQuery = { $pull:{} }
      removeDetailQuery.$pull.details = self.details[detailIndex]
      recalculationOrder(self._id) if Document.Order.update(self._id, removeDetailQuery, callback)

    doc.submit = ->
      return console.log('Order không tồn tại.') if (!self = Document.Order.findOne doc._id)
      return console.log('Order đã Submit') if self.orderType isnt Enum.orderType.created

      for detail, detailIndex in self.details
        product = Document.Product.findOne({'units._id': detail.productUnit})
        return console.log('Khong tim thay Product') if !product
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        return console.log('Khong tim thay ProductUnit') if !productUnit
      Meteor.call 'orderSubmit', self._id

    doc.addDelivery = (option, callback) ->
      return console.log('Order không tồn tại.') if (!self = Document.Order.findOne doc._id)
      return console.log('Customer không tồn tại.') if (!customer = Document.Customer.findOne(self.buyer))
      return console.log('Delivery tồn tại.') if self.deliveryStatus

      addDeliver = {$push: {}}
      addDeliver.description        = option.description if Math.check(option.deliveryDate, String)
      addDeliver.deliveryDate       = option.deliveryDate if Math.check(option.deliveryDate, Date)
      addDeliver.contactName        = option.name ? customer.name
      addDeliver.contactPhone       = option.phone ? customer.phone
      addDeliver.deliveryAddress    = option.address ? customer.address
      addDeliver.transportationFee  = 0
      addDeliver.createdAt          = new Date()

      Document.Order.update self._id, addDeliver, callback

    doc.deliveryReceipt = (staffId = Meteor.userId(), callback)->
      return console.log('Order không tồn tại.') if (!self = Document.Order.findOne doc._id)
      return console.log('Delivery tồn tại.') unless self.deliveryStatus
      return console.log('Delivery đang được giao.') if self.deliveryStatus isnt Enum.created
      return console.log('Staff không tồn tại.') if !@Meteor.users.findOne(staffId)

      deliveryLastIndex = self.deliveries.length - 1
      deliveryReceiptUpdate = {$set:{}}
      deliveryReceiptUpdate.$set['deliveries.'+deliveryLastIndex +'.shipper'] = staffId
      Document.Order.update self._id, deliveryReceiptUpdate, callback

    doc.deliverySucceed = (staffId = Meteor.userId(), callback)->
      deliveryLastIndex = self.deliveries.length - 1
      deliveryReceiptUpdate = {$unset:{}}
      deliveryReceiptUpdate.$unset['deliveries.'+deliveryLastIndex +'.shipper'] = ""
      Document.Order.update self._id, deliveryReceiptUpdate, callback

Module "Enum",
  orderType:
    created   : 0
    submitted : 1

  deliveryStatus:
    created  : 0
    delivered: 1
    succeed  : 2

Document.Order.attachSchema new SimpleSchema
  saleCode:
    type: String
    index: 1
    unique: true
    autoValue: -> return Random.id() if @isInsert

  branch:
    type: String
    optional: true

  buyer:
    type: String
    optional: true

  orderName:
    type: String
    defaultValue: 'ĐƠN HÀNG'

  description:
    type: String
    optional: true

  orderType:
    type: Number
    defaultValue: Enum.orderType.created

  creator   : Schema.creator
  slug      : Schema.clone('saleCode')
  version   : { type: Schema.version }

  returns     : type: [String],  optional: true
  discountCash: type: Number , defaultValue: 0
  depositCash : type: Number , defaultValue: 0
  totalPrice  : type: Number , defaultValue: 0
  finalPrice  : type: Number , defaultValue: 0
  allowDelete : type: Boolean, defaultValue: true

  details: type: [Object], defaultValue: []
  'details.$._id'          : Schema.uniqueId
  'details.$.product'      : type: String
  'details.$.productUnit'  : type: String
  'details.$.quality'      : {type: Number, min: 0}
  'details.$.price'        : {type: Number, min: 0}
  'details.$.basicQuality' : {type: Number, min: 0}
  'details.$.returnQuality': Schema.defaultNumber()


  deliveryStatus                  : type: Number  , optional: true
  deliveries                      : type: [Object], defaultValue: []
  'deliveries.$.shipper'          : type: String  , optional: true
  'deliveries.$.buyer'            : type: String  , optional: true
  'deliveries.$.deliveryCode'     : type: String  , optional: true
  'deliveries.$.contactName'      : type: String  , optional: true
  'deliveries.$.description'      : type: String  , optional: true
  'deliveries.$.contactPhone'     : type: String  , optional: true
  'deliveries.$.deliveryAddress'  : type: String  , optional: true
  'deliveries.$.deliveryDate'     : type: String  , optional: true
  'deliveries.$.transportationFee': type: Number  , optional: true
  'deliveries.$.createdAt'        : type: Date    , optional: true

