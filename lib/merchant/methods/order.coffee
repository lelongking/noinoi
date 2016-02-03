Enums = Apps.Merchant.Enums

checkProductInStockQuantity = (orderDetails)->
  details = _.chain(orderDetails)
  .groupBy("product")
  .map (group, key) ->
    return {
    product      : group[0].product
    basicQuantity : _.reduce( group, ((res, current) -> res + current.basicQuantity), 0 )
    }
  .value()

  result = {valid: true, errorItem: []}
  if details.length > 0
    for currentDetail in details
      currentProduct = Document.Product.findOne(currentDetail.product)
      console.log currentProduct.merchantQuantities[0].availableQuantity
      if currentProduct.merchantQuantities[0].availableQuantity < currentDetail.basicQuantity
        result.errorItem.push detail for detail in _.where(orderDetails, {product: currentDetail.product})
        (result.valid = false; result.message = "sản phẩm không đủ số lượng") if result.valid
  else
    result = {valid: false, message: "Danh sách sản phẩm trống." }

  return result

subtractQuantityOnSales = (importDetails, saleDetail) ->
  transactionQuantity = 0
  for importDetail in importDetails
    requiredQuantity = saleDetail.basicQuantity - transactionQuantity
    takenQuantity = if importDetail.availableQuantity > requiredQuantity then requiredQuantity else importDetail.availableQuantity

    updateProduct = {availableQuantity: -takenQuantity, inStockQuantity: -takenQuantity, saleQuantity: takenQuantity}

    transactionQuantity += takenQuantity
    if transactionQuantity == saleDetail.basicQuantity then break

  return transactionQuantity == saleDetail.basicQuantity

createTransaction = (customer, order)->
  debitCash = (customer.saleAmount ? 0) + (customer.loanAmount ? 0) + (customer.returnPaidAmount ? 0)
  paidCash  = (customer.returnAmount ? 0) + (customer.paidAmount ? 0)

  createTransactionOfSale =
    name         : 'Phiếu Bán'
    balanceType  : Enums.getValue('TransactionTypes', 'saleAmount')
    receivable   : true
    isRoot       : true
    owner        : customer._id
    parent       : order._id
    isUseCode    : false
    isPaidDirect : false
    balanceBefore: debitCash - paidCash
    balanceChange: order.finalPrice
    balanceLatest: debitCash - paidCash + order.finalPrice
  createTransactionOfSale.description = order.description if order.description

  if transactionSaleId = Schema.transactions.insert(createTransactionOfSale)
    if order.depositCash > 0 #co tra tien
      createTransactionOfDepositSale =
        name         : 'Phiếu Thu Tiền'
        description  : 'Thanh toán phiếu: ' + order.orderCode
        balanceType  : Enums.getValue('TransactionTypes', 'customerPaidAmount')
        receivable   : false
        isRoot       : false
        owner        : customer._id
        parent       : order._id
        isUseCode    : true
        isPaidDirect : true
        balanceBefore: debitCash - paidCash + order.finalPrice
        balanceChange: order.depositCash
        balanceLatest: debitCash - paidCash + order.finalPrice - order.depositCash

      Schema.transactions.insert(createTransactionOfDepositSale)

    customerUpdate =
      paidAmount  : order.depositCash
      saleAmount  : order.finalPrice

    Schema.customers.update order.buyer, { $inc: customerUpdate, $set: {allowDelete : false} }
    Schema.customerGroups.update order.group, $inc:{totalCash: order.finalPrice - order.depositCash} if customer.group

  return transactionSaleId

updateSubtractQuantityInProductUnit = (product, orderDetail) ->
  detailIndex = 0; updateProductQuery = {$inc:{}}
  updateProductQuery.$inc["merchantQuantities.#{detailIndex}.saleQuantity"]    = orderDetail.basicQuantity
  updateProductQuery.$inc["merchantQuantities.#{detailIndex}.inOderQuantity"]  = -orderDetail.basicQuantity
  updateProductQuery.$inc["merchantQuantities.#{detailIndex}.inStockQuantity"] = -orderDetail.basicQuantity

  if Schema.products.update(product._id, updateProductQuery)
    if product.inventoryInitial
      inStockQuantity = product.merchantQuantities[0].inStockQuantity - orderDetail.basicQuantity
      normsQuantity   = product.merchantQuantities[0].lowNormsQuantity
      optionQuantity =
        notificationType: 'notify'
        product         : product._id
        group           : Enums.getObject('NotificationGroups')['productQuantity'].value
      productQuantityFound = Schema.notifications.findOne(optionQuantity)
      if inStockQuantity > 0
        if normsQuantity > inStockQuantity
          optionQuantity.message = "Sản phẩm #{product.name} sắp hết hàng. (còn #{inStockQuantity}/#{normsQuantity} #{product.units[0].name})"
          if productQuantityFound
            Schema.notifications.update productQuantityFound._id, $set:{message: optionQuantity.message}
          else
            Schema.notifications.insert optionQuantity

        else
          Schema.notifications.remove(productQuantityFound._id) if productQuantityFound

      else
        optionQuantity.message = "Sản phẩm #{product.name} đã hết hàng."
        if productQuantityFound
          Schema.notifications.update productQuantityFound._id, $set:{message: optionQuantity.message}
        else
          Schema.notifications.insert optionQuantity




findAllImport = (productId) ->
  basicImport = Schema.imports.find({
    importType                      : $in:[Enums.getValue('ImportTypes', 'inventorySuccess'), Enums.getValue('ImportTypes', 'success')]
    'details.product'               : productId
    'details.basicQuantityAvailable': {$gt: 0}
  }, {sort: {importType: 1} }).fetch()
  combinedImports = basicImport; console.log combinedImports
  combinedImports

updateSubtractQuantityInImport = (orderFound, orderDetail, detailIndex, combinedImports) ->
  transactionQuantity = 0
  for currentImport in combinedImports #danh sach phieu Import
    for importDetail, index in currentImport.details #danh sach ImportDetail
      if importDetail.product is orderDetail.product #so sanh ProductUnit
        requiredQuantity = orderDetail.basicQuantity - transactionQuantity

        availableQuantity = importDetail.basicQuantityAvailable - requiredQuantity
        if availableQuantity > 0
          takenQuantity = requiredQuantity
#          orderDetailNote = "còn #{availableQuantity}, phiếu #{currentImport.importCode}"
        else
          takenQuantity = importDetail.basicQuantityAvailable
#          orderDetailNote = "hết hàng, phiếu #{currentImport.importCode}"

        if takenQuantity > 0
          console.log 'basicQuantity', orderDetail.basicQuantity
          console.log 'transactionQuantity', transactionQuantity
          console.log 'basicQuantityAvailable', importDetail.basicQuantityAvailable
          console.log 'importDetail', orderDetail

          updateOrderQuery = {$push:{}, $inc:{}}
#          importDetailOfOrder =
#            _id         : currentImport._id
#            detailId    : importDetail._id
#            product     : importDetail.product
#            productUnit : orderDetail.productUnit
#            provider    : currentImport.provider
#            price       : orderDetail.price
#            conversion  : orderDetail.conversion
#            quality     : takenQuantity/orderDetail.conversion
#  #          note        : orderDetailNote
#            createdAt   : new Date()
#            basicQuantity          : takenQuantity
#            basicQuantityReturn    : 0
#            basicQuantityAvailable : takenQuantity

#          updateOrderQuery.$push["details.#{detailIndex}.imports"]                 = importDetailOfOrder
          updateOrderQuery.$inc["details.#{detailIndex}.basicImportQuantity"]      = takenQuantity
          updateOrderQuery.$inc["details.#{detailIndex}.basicImportQuantityDebit"] = -takenQuantity

          if transactionQuantity is orderDetail.basicQuantity
            updateOrderQuery.$set = {}
            updateOrderQuery.$set["details.#{detailIndex}.importIsValid"] = true
          console.log 'updateOrderQuery'
          console.log updateOrderQuery
          if Schema.orders.update(orderFound._id, updateOrderQuery)
            updateImport = $inc:{}
            updateImport.$inc["details.#{index}.basicOrderQuantity"]     = takenQuantity
            updateImport.$inc["details.#{index}.basicQuantityAvailable"] = -takenQuantity
            Schema.imports.update currentImport._id, updateImport

        transactionQuantity += takenQuantity
        break if transactionQuantity is orderDetail.basicQuantity
    break if transactionQuantity is orderDetail.basicQuantity


Meteor.methods
  testMethods: ->
    if Meteor.isClient
      console.log 'isClient'

  customerToOrder: (customerId)->
    try
      user = Meteor.users.findOne(Meteor.userId())
      throw {valid: false, error: 'user not found!'} unless user

      customer = Schema.customers.findOne({_id: customerId, merchant: user.profile.merchant})
      throw {valid: false, error: 'customer not found!'} unless customer

      orderFound = Schema.orders.findOne({
        seller      : user._id
        buyer       : customer._id
        merchant    : user.profile.merchant
        orderType   : Enums.getValue('OrderTypes', 'initialize')
        orderStatus : Enums.getValue('OrderStatus', 'initialize')
      }, {sort: {'version.createdAt': -1}})

      if orderFound
        Order.setSession(orderFound._id)
      else
        Order.setSession(orderId) if orderId = Order.insert(customer._id, user._id, customer.name)

    catch error
      throw new Meteor.Error('customerToOrder', error)

  customerToReturn: (customerId)->
    try
      user = Meteor.users.findOne(Meteor.userId())
      throw {valid: false, error: 'user not found!'} if !user

      customer = Schema.customers.findOne({_id: customerId, merchant: user.profile.merchant})
      throw {valid: false, error: 'customer not found!'} unless customer

      returnFound = Schema.returns.findOne({
        creator     : user._id
        owner       : customer._id
        returnType  : Enums.getValue('ReturnTypes', 'customer')
        returnStatus: Enums.getValue('ReturnStatus', 'initialize')
        merchant    : user.profile.merchant
      }, {sort: {'version.createdAt': -1}})

      if returnFound
        Return.setReturnSession(returnFound._id, 'customer')
      else
        returnType = Enums.getValue('ReturnTypes', 'customer')
        if returnId = Return.insert(returnType, customer._id)
          Return.setReturnSession(returnId, 'customer')

    catch error
      throw new Meteor.Error('customerToReturn', error)

  deleteOrder: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user
    return {valid: false, error: 'user not permission!'} unless User.hasManagerRoles()

    merchant = Schema.merchants.findOne({_id: user.profile.merchant}) if user.profile
    return {valid: false, error: 'user not found!'} unless merchant

    query =
      buyer       : $exists: true
      merchant    : merchant._id
      orderType   : Enums.getValue('OrderTypes', 'success')
      orderStatus : Enums.getValue('OrderStatus', 'finish')

    currentOrderQuery = _.clone(query)
    currentOrderQuery._id = orderId

    console.log 'ok1'
    currentOrderFound = Schema.orders.findOne currentOrderQuery
    return {valid: false, error: 'order not found!'} unless currentOrderFound
#    return {valid: false, error: 'order not delete!'} unless currentOrderFound.allowDelete
    console.log 'ok2'
    customerFound = Schema.customers.findOne(currentOrderFound.buyer)
    return {valid: false, error: 'customer not found!'} unless customerFound

    console.log 'ok3'
    returnFound = Schema.returns.findOne({
      merchant    : currentOrderFound.merchant
      parent      : currentOrderFound._id
      returnType  : Enums.getValue('ReturnTypes', 'customer')
      returnStatus: Enums.getValue('ReturnStatus', 'success')
    })
    console.log returnFound
    return {valid: false, error: 'return found!'} if returnFound

    productLists = []
    for item in currentOrderFound.details
      product = Schema.products.findOne(item.product)
      return {valid: false, error: 'product not found!'} unless product
      productLists.push(product)



    if Schema.orders.remove(currentOrderFound._id)
      for orderDetail in currentOrderFound.details
        product = _.findWhere(productLists, {_id: orderDetail.product})

        updateProductQuery =
          $inc:
            'merchantQuantities.0.saleQuantity'     : -orderDetail.basicQuantity
            'merchantQuantities.0.availableQuantity': orderDetail.basicQuantity
            'merchantQuantities.0.inStockQuantity'  : orderDetail.basicQuantity
        Schema.products.update product._id, updateProductQuery


      console.log
      if parseInt(customerFound.saleBillNo) is parseInt(currentOrderFound.billNoOfBuyer)
        Schema.customers.update customerFound._id, $inc:{saleBillNo: -1}

      if parseInt(merchant.saleBillNo) is parseInt(currentOrderFound.billNoOfMerchant)
        Schema.merchants.update merchant._id, $inc:{saleBillNo: -1}



      Schema.transactions.find(
        $and: [
          merchant : currentOrderFound.merchant
          owner    : currentOrderFound.buyer
          parent   : currentOrderFound._id
        ,
          $or: [{isRoot: true}, {isPaidDirect : true}]
        ]
      ).forEach(
        (transaction)->
          Meteor.call 'deleteTransaction', transaction._id
      )
      Meteor.call 'reCalculateCustomerInterestAmount', customerFound._id








Meteor.methods
  orderSellerConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      seller      : user._id
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'initialize')
      orderStatus : Enums.getValue('OrderStatus', 'initialize')
    orderFound = Schema.orders.findOne orderQuery

    return {valid: false, error: 'order not found!'} unless orderFound

    buyer = Schema.customers.findOne(orderFound.buyer)
    return {valid: false, error: 'buyer not found!'} unless buyer

    merchant = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchant

    for detail, detailIndex in orderFound.details
      product = Schema.products.findOne({'units._id': detail.productUnit})
      return {valid: false, error: 'productUnit not found!'} unless product

    customerBillNo = Helpers.orderCodeCreate(buyer.saleBillNo ? '00')
    merchantBillNo = Helpers.orderCodeCreate(merchant.saleBillNo ? '00')

    orderUpdate = $set:
      orderType        : Enums.getValue('OrderTypes', 'tracking')
      orderStatus      : Enums.getValue('OrderStatus', 'sellerConfirm')
      sellerConfirmAt  : new Date()
      billNoOfBuyer    : customerBillNo
      billNoOfMerchant : merchantBillNo
      orderCode        : customerBillNo + '/' + merchantBillNo
    console.log orderUpdate

    if Schema.orders.update(orderFound._id, orderUpdate)
      Schema.customers.update(buyer._id, $inc: {saleBillNo: 1})
      Schema.merchants.update(merchant._id, $inc: {saleBillNo: 1})

      optionNewOrder =
        notificationType: 'notify'
        group           : Enums.getObject('NotificationGroups')['newOrder'].value
        message         : "Nhân viên #{user.profile.name} tạo phiếu bán cho khách hàng #{buyer.name}"
        reads           : [Meteor.userId()]
      Schema.notifications.insert(optionNewOrder)


  orderAccountConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'sellerConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    for productId, details of _.groupBy(orderFound.details, (item) -> item.product)
      if product = Schema.products.findOne(productId)
        availableQuantity = product.merchantQuantities[0].availableQuantity ? 0

        saleQuantity  = 0
        for orderDetail in details
          saleQuantity += orderDetail.basicQuantity

        if product.inventoryInitial and (availableQuantity - saleQuantity) < 0
          return {valid: false, error: 'san pham khong du!'}

      else
        return {valid: false, error: 'khong tim thay product!'}

    orderUpdate = $set:
      orderStatus        : Enums.getValue('OrderStatus', 'accountingConfirm')
      accounting         : Meteor.userId()
      accountingConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

    if Schema.customers.update(orderFound.buyer, $addToSet:{orderWaiting: orderFound._id})
      buyer = Schema.customers.findOne(orderFound.buyer)
      optionNewOrder =
        notificationType: 'notify'
        sender          : Meteor.userId()
        receiver        : orderFound.seller
        group           : Enums.getObject('NotificationGroups')['newOrder'].value
        message         : "Nhân viên #{user.profile.name} đã ghi nhận phiếu của khách hàng #{buyer.name}"
        reads           : [Meteor.userId()]
      Schema.notifications.insert(optionNewOrder)

#    updateUserId = if orderFound.staff then orderFound.staff else orderFound.seller
#    Meteor.users.update(updateUserId, $inc:{'profile.turnoverCash': orderFound.finalPrice})


  orderExportConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'accountingConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    for detail in orderFound.details
      if product = Schema.products.findOne(detail.product)
        updateQuery = $inc:
          'merchantQuantities.0.inOderQuantity'    : detail.basicQuantity
          'merchantQuantities.0.availableQuantity' : -detail.basicQuantity

        console.log updateQuery
        Schema.products.update product._id, updateQuery

    orderUpdate = $set:
      orderStatus    : Enums.getValue('OrderStatus', 'exportConfirm')
      export         : Meteor.userId()
      exportConfirmAt: new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderSuccessConfirm: (orderId, success = true)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'exportConfirm')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    if success
      orderUpdate = $set:
        orderType   : Enums.getValue('OrderTypes', 'success')
        orderStatus : Enums.getValue('OrderStatus', 'success')
      Schema.orders.update orderFound._id, orderUpdate
    else
      orderUpdate = $set:
        orderType   : Enums.getValue('OrderTypes', 'fail')
        orderStatus : Enums.getValue('OrderStatus', 'fail')
      Schema.orders.update orderFound._id, orderUpdate

  orderUndoConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : {$in:[
        Enums.getValue('OrderTypes', 'success')
        Enums.getValue('OrderTypes', 'fail')
      ]}
      orderStatus : {$in:[
        Enums.getValue('OrderStatus', 'success')
        Enums.getValue('OrderStatus', 'fail')
      ]}
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    orderUpdate = $set:
      orderType   : Enums.getValue('OrderTypes', 'tracking')
      orderStatus : Enums.getValue('OrderStatus', 'exportConfirm')
    Schema.orders.update orderFound._id, orderUpdate

  orderImportConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : Enums.getValue('OrderTypes', 'fail')
      orderStatus : Enums.getValue('OrderStatus', 'fail')
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    for detail, detailIndex in orderFound.details
      if product = Schema.products.findOne(detail.product)
        updateQuery = $inc:
          'merchantQuantities.0.inOderQuantity': -detail.basicQuantity
          'merchantQuantities.0.availableQuantity':detail.basicQuantity
        Schema.products.update product._id, updateQuery

    orderUpdate = $set:
      orderStatus     : Enums.getValue('OrderStatus', 'importConfirm')
      import          : Meteor.userId()
      importConfirmAt : new Date()
    Schema.orders.update orderFound._id, orderUpdate

  orderFinishConfirm: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id         : orderId
      merchant    : user.profile.merchant
      orderType   : {$in:[Enums.getValue('OrderTypes', 'success'), Enums.getValue('OrderTypes', 'fail')]}
      orderStatus : {$in:[Enums.getValue('OrderStatus', 'success'), Enums.getValue('OrderStatus', 'importConfirm')]}
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    customerFound = Schema.customers.findOne(orderFound.buyer)
    return {valid: false, error: 'customer not found!'} unless customerFound

    merchantFound = Schema.merchants.findOne(user.profile.merchant)
    return {valid: false, error: 'merchant not found!'} unless merchantFound

    if orderFound.orderType is Enums.getValue('OrderTypes', 'success')
      customerFound = Schema.customers.findOne(orderFound.buyer)
      return {valid: false, error: 'customer not found!'} unless customerFound

      transactionId = createTransaction(customerFound, orderFound)
      return {valid: false, error: 'customer not found!'} unless transactionId

      for orderDetail, detailIndex in orderFound.details
        if product = Schema.products.findOne({'units._id': orderDetail.productUnit})
          updateSubtractQuantityInProductUnit(product, orderDetail)

#          if product.inventoryInitial
#            combinedImports = findAllImport(orderDetail.product)
#            updateSubtractQuantityInImport(orderFound, orderDetail, detailIndex, combinedImports)

      updateOrderQuery = $set:
        orderStatus : Enums.getValue('OrderStatus', 'finish')
        transaction : transactionId
        successDate : new Date()
#        orderCode   :"#{Helpers.orderCodeCreate(customerFound.saleBillNo)}/#{Helpers.orderCodeCreate(merchantFound.saleBillNo)}"

      if Schema.orders.update(orderFound._id, updateOrderQuery)
        buyer = Schema.customers.findOne(orderFound.buyer)
        optionNewOrder =
          notificationType: 'notify'
          sender          : Meteor.userId()
          receiver        : orderFound.seller
          group           : Enums.getObject('NotificationGroups')['newOrder'].value
          message         : "Nhân viên #{user.profile.name} xác nhận hoàn thành phiếu của khách hàng #{buyer.name}"
          reads           : [Meteor.userId()]
        Schema.notifications.insert(optionNewOrder)

        Schema.customers.update customerFound._id, {
          $inc: {saleBillNo: 0, transactionBillNo: 0}
          $addToSet:{orderSuccess: orderFound._id}
          $pull: {orderWaiting: orderFound._id}}
        Schema.merchants.update(merchantFound._id, $inc:{saleBillNo: 0, transactionBillNo: 0})


    else
      if Number(orderFound.orderCode.split('/')[0]) is customerFound.saleBillNo
        Schema.customers.update customerFound._id, $inc: {saleBillNo: -1}
      orderUpdate = $set:
        orderStatus : Enums.getValue('OrderStatus', 'finish')
      Schema.orders.update orderFound._id, orderUpdate
      Schema.customers.update orderFound.buyer, {$addToSet:{orderFailure: orderFound._id}, $pull: {orderWaiting: orderFound._id}}


Meteor.methods
  orderSuccessConfirmed: (orderId)->
    user = Meteor.users.findOne(Meteor.userId())
    return {valid: false, error: 'user not found!'} unless user

    orderQuery =
      _id       : orderId
      creator   : user._id
      merchant  : user.profile.merchant
      orderType : $in: [Enums.getValue('OrderTypes', 'export'),Enums.getValue('OrderTypes', 'import')]
    orderFound = Schema.orders.findOne orderQuery
    return {valid: false, error: 'order not found!'} unless orderFound

    if orderFound.paymentsDelivery is Enums.getValue('DeliveryTypes', 'delivery') and
      (orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'unDelivered') or
        orderFound.delivery.status is Enums.getValue('DeliveryStatus', 'delivered'))
      return {valid: false, error: 'Delivery not finish!'}

    Schema.orders.update orderFound._id, $set: { orderType : Enums.getValue('OrderTypes', 'success') }
