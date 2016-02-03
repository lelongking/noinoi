Enums = Apps.Merchant.Enums
Meteor.methods
  deleteReturn: (returnId, ownerId, returnType = Enums.getValue('ReturnTypes', 'customer'))->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user
    return {valid: false, error: 'user not permission!'} unless User.hasManagerRoles()

    merchantFound = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchantFound

    returnTypes = [Enums.getValue('ReturnTypes', 'customer'), Enums.getValue('ReturnTypes', 'provider')]
    return {valid: false, error: 'returnType is valid!'} unless _.contains(returnTypes, returnType)

    query =
      owner        : ownerId
      parent       : $exists: true
      merchant     : user.profile.merchant
      returnType   : returnType
      returnStatus : Enums.getValue('ReturnStatus', 'success')

    currentReturnQuery = _.clone(query)
    currentReturnQuery._id = returnId

    currentReturnFound = Schema.returns.findOne currentReturnQuery
    return {valid: false, error: 'return not found!'} unless currentReturnFound
    return {valid: false, error: 'return not delete!'} unless currentReturnFound.allowDelete

    parent =
      if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'customer')
        Schema.orders.findOne(
          _id        : currentReturnFound.parent
          merchant   : currentReturnFound.merchant
          orderType  : Enums.getValue('OrderTypes', 'success')
          orderStatus: Enums.getValue('OrderStatus', 'finish')
        )
      else if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'provider')
        Schema.imports.findOne(
          _id        : currentReturnFound.parent
          merchant   : currentReturnFound.merchant
          importType : Enums.getValue('ImportTypes', 'success')
        )
    return {valid: false, error: 'parent not found!'} unless parent


    for item in currentReturnFound.details
      product = Schema.products.findOne(item.product)
      return {valid: false, error: 'product not found!'} unless product



    if Schema.returns.remove(currentReturnFound._id)
      basicQuantity = 0
      for returnDetail in currentReturnFound.details
        basicQuantity += returnDetail.basicQuantity
        if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'customer')
          productUpdate =
            $inc:
              'merchantQuantities.0.inStockQuantity'    : -returnDetail.basicQuantity
              'merchantQuantities.0.availableQuantity'  : -returnDetail.basicQuantity
              'merchantQuantities.0.returnSaleQuantity' : -returnDetail.basicQuantity
        else if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'provider')
          productUpdate =
            $inc:
              'merchantQuantities.0.inStockQuantity'      : returnDetail.basicQuantity
              'merchantQuantities.0.availableQuantity'    : returnDetail.basicQuantity
              'merchantQuantities.0.returnImportQuantity' : -returnDetail.basicQuantity
        Schema.products.update returnDetail.product, productUpdate

      if basicQuantity > 0
        parentUpdate = $inc:{}

        for detail, index in parent.details
          if detail.basicQuantityReturn > 0 and basicQuantity > 0
            if basicQuantity > detail.basicQuantityReturn
              parentUpdate.$inc["details.#{index}.basicQuantityReturn"]    = -detail.basicQuantityReturn
              parentUpdate.$inc["details.#{index}.basicQuantityAvailable"] = detail.basicQuantityReturn
              basicQuantity += -detail.basicQuantityReturn
            else
              parentUpdate.$inc["details.#{index}.basicQuantityReturn"]    = -basicQuantity
              parentUpdate.$inc["details.#{index}.basicQuantityAvailable"] = basicQuantity
              basicQuantity = 0

        if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'customer')
          Schema.orders.update(parent._id, parentUpdate) if _.keys(parentUpdate.$inc).length > 0
        else if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'provider')
          Schema.imports.update(parent._id, parentUpdate) if _.keys(parentUpdate.$inc).length > 0


      Schema.transactions.find(
        $and: [
          merchant : currentReturnFound.merchant
          owner    : currentReturnFound.owner
          parent   : currentReturnFound._id
        ,
          $or: [{isRoot: true}, {isPaidDirect : true}]
        ]
      ).forEach(
        (transaction)->
          Meteor.call 'deleteTransaction', transaction._id
      )


      returnFound = Schema.returns.findOne(
        owner        : currentReturnFound.owner
        parent       : currentReturnFound.parent
        merchant     : currentReturnFound.merchant
        returnType   : currentReturnFound.returnType
        returnStatus : Enums.getValue('ReturnStatus', 'success')
      )
      unless returnFound
        if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'customer')
          Schema.orders.update(currentReturnFound.parent, $set: {allowDelete: true})
        else if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'provider')
          Schema.imports.update(currentReturnFound.parent, $set: {allowDelete: true})