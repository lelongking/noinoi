Wings.defineWidget 'providerImportDetails',
  helpers:
    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1
    isColor: -> '#fff'
#      if Template.parentData().classColor then '#fff' else '#f0f0f0'
    allowDelete: -> @_id isnt Template.parentData().transaction
    billNo: ->
      if @model is 'imports'
        'Phiếu ' + @billNoOfProvider #+ if @description then " (#{@description})" else ''
      else if @model is 'returns'
        'Trả hàng theo phiếu ' + @returnCode #+ if @description then " (#{@description})" else ''

    productUnitPrice: -> @price * @conversion

    detail: ->
      detail = @
      detail.totalPrice = detail.basicQuantity * detail.price

      if product = Schema.products.findOne({'units._id': detail.productUnit})
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        detail.productName     = product.name
        detail.basicUnitName   = product.unitName()
        detail.productUnitName = productUnit.name

      detail

  events:
    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id
      event.stopPropagation()

