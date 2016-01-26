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
      for orderDetail in currentReturnFound.details
        if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'customer')
          productUpdate =
            $inc:
              'merchantQuantities.0.inStockQuantity'    : -orderDetail.basicQuantity
              'merchantQuantities.0.returnSaleQuantity' : -orderDetail.basicQuantity
              'merchantQuantities.0.availableQuantity'  : -orderDetail.basicQuantity
        else if currentReturnFound.returnType is Enums.getValue('ReturnTypes', 'provider')
          productUpdate =
            $inc:
              'merchantQuantities.0.inStockQuantity'    : orderDetail.basicQuantity
              'merchantQuantities.0.returnSaleQuantity' : orderDetail.basicQuantity
              'merchantQuantities.0.availableQuantity'  : orderDetail.basicQuantity
        Schema.products.update orderDetail.product, productUpdate


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