Meteor.methods
  importSubmit: (importId) ->
    importFound = Document.Import.findOne(importId)
    return if importFound.importType is Enum.importType.submitted
#    return if !importFound.provider

    updateImport  = {$set:{importType: Enum.importType.submitted}}
    updateProduct = {$set:{totalPrice: 0}}

    for detail, detailIndex in importFound.details
      product = Document.Product.findOne({'units._id': detail.productUnit})
      return console.log('Khong tim thay Product') if !product
      productUnit = _.findWhere(product.units, {_id: detail.productUnit})
      return console.log('Khong tim thay ProductUnit') if !productUnit
      productUnitIndex = _.indexOf(product.units, productUnit)
      updateProduct.$set['units.'+[productUnitIndex]+'.allowDelete'] = false

      updateImport.$set.totalPrice += detail.quality * detail.price
      baseQuality = productUnit.conversion * detail.quality
      updateImport.$set['details.'+detailIndex+'.availableQuality']    = baseQuality
      updateImport.$set['details.'+detailIndex+'.inStockQuality']      = baseQuality
      updateImport.$set['details.'+detailIndex+'.importQuality']       = baseQuality

#      productQuality = _.findWhere(product.qualities, {branch: ????}) khi co Branch
#      qualityIndex = _.indexOf(product.qualities, productQuality)
      productQuality = product.qualities[0]
      qualityIndex = 0
      updateProduct.$set['qualities.'+qualityIndex+'.availableQuality']    = baseQuality + productQuality.availableQuality
      updateProduct.$set['qualities.'+qualityIndex+'.inStockQuality']      = baseQuality + productQuality.inStockQuality
      updateProduct.$set['qualities.'+qualityIndex+'.importQuality']       = baseQuality + productQuality.importQuality
      Document.Product.update(product._id, updateProduct)

    updateImport.$set.finalPrice = updateImport.$set.totalPrice - detail.discountCash
    Document.Import.update(importFound._id, updateImport)

