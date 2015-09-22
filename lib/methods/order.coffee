checkProductInStockQuality = (orderDetails)->
  details = _.chain(orderDetails)
  .groupBy("product")
  .map (group, key) ->
    return {
      product      : group[0].product
      basicQuality : _.reduce( group, ((res, current) -> res + current.basicQuality), 0 )
    }
  .value()

  result = {valid: true, errorItem: []}
  if details.length > 0
    for currentDetail in details
      currentProduct = Document.Product.findOne(currentDetail.product)
      console.log currentProduct.qualities[0].availableQuality
      if currentProduct.qualities[0].availableQuality < currentDetail.basicQuality
        result.errorItem.push detail for detail in _.where(orderDetails, {product: currentDetail.product})
        (result.valid = false; result.message = "sản phẩm không đủ số lượng") if result.valid
  else
    result = {valid: false, message: "Danh sách sản phẩm trống." }

  return result

subtractQualityOnSales = (importDetails, saleDetail) ->
  transactionQuality = 0
  for importDetail in importDetails
    requiredQuality = saleDetail.basicQuality - transactionQuality
    takenQuality = if importDetail.availableQuality > requiredQuality then requiredQuality else importDetail.availableQuality

    updateProduct = {availableQuality: -takenQuality, inStockQuality: -takenQuality, saleQuality: takenQuality}

    transactionQuality += takenQuality
    if transactionQuality == saleDetail.basicQuality then break

  return transactionQuality == saleDetail.basicQuality

Meteor.methods
  orderSubmit: (orderId) ->
    orderFound = Document.Order.findOne(orderId)
    return if orderFound.orderType isnt Enum.orderType.created

    result = checkProductInStockQuality(orderFound.details)
    if result.valid
      for orderDetail in orderFound.details
        importDetails = []
        imports = Document.Import.find(
          {'details.product': orderDetail.product, 'details.availableQuality': {$gt: 0}, importType: Enum.importType.submitted}
          {sort: {'version.createdAt': 1}}
        ).fetch()
        importDetails.push(item) for item in imports

#        if subtractQualityOnSales(importDetails, orderDetail)
          #update Order