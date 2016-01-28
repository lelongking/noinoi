Enums = Apps.Merchant.Enums
Meteor.publish null, ->
  return if !@userId
  myProfile  = Meteor.users.findOne(@userId)?.profile
  merchantId = myProfile.merchant if myProfile
  return if !merchantId

  #all
  Counts.publish @, 'products', Schema.products.find({merchant: merchantId})
  Counts.publish @, 'productGroups', Schema.productGroups.find({merchant: merchantId, isBase: false})

  Counts.publish @, 'customers', Schema.customers.find({merchant: merchantId})
  Counts.publish @, 'customerReturns', Schema.returns.find({returnType: 0, merchant: merchantId})
  Counts.publish @, 'customerGroups', Schema.customerGroups.find({merchant: merchantId, isBase: false})


  gridOrderQuery =
    merchant: merchantId
    orderType: {$in:[
      Enums.getValue('OrderTypes', 'tracking')
      Enums.getValue('OrderTypes', 'success')
      Enums.getValue('OrderTypes', 'fail')
    ]}
    orderStatus: {$in:[
      Enums.getValue('OrderStatus', 'accountingConfirm')
      Enums.getValue('OrderStatus', 'exportConfirm')
      Enums.getValue('OrderStatus', 'success')
      Enums.getValue('OrderStatus', 'fail')
      Enums.getValue('OrderStatus', 'importConfirm')
    ]}
  Counts.publish @, 'deliveries', Schema.orders.find(gridOrderQuery)

  Counts.publish @, 'providers', Schema.providers.find({merchant: merchantId})
  Counts.publish @, 'providerReturns', Schema.returns.find({returnType: 1, merchant: merchantId})

  Counts.publish @, 'imports', Schema.imports.find(
    creator   : @userId
    merchant  : merchantId
    importType: Enums.getValue('ImportTypes', 'initialize')
  )
  Counts.publish @, 'inventories', Schema.inventories.find({merchant: merchantId})

  Counts.publish @, 'staffs', Meteor.users.find({'profile.merchant': merchantId})
  Counts.publish @, 'priceBooks', Schema.priceBooks.find({merchant: merchantId})

  orderQuery =
    creator     : @userId
    merchant    : merchantId
    orderType   : Enums.getValue('OrderTypes', 'initialize')
    orderStatus : Enums.getValue('OrderStatus', 'initialize')
  Counts.publish @, 'orders', Schema.orders.find(orderQuery)

  billQuery =
    merchant    : merchantId
    orderType   : {$in:[
      Enums.getValue('OrderTypes', 'tracking')
      Enums.getValue('OrderTypes', 'success')
      Enums.getValue('OrderTypes', 'fail')
    ]}
    orderStatus : {$in:[
      Enums.getValue('OrderStatus', 'sellerConfirm')
      Enums.getValue('OrderStatus', 'accountingConfirm')
      Enums.getValue('OrderStatus', 'exportConfirm')
      Enums.getValue('OrderStatus', 'success')
      Enums.getValue('OrderStatus', 'fail')
      Enums.getValue('OrderStatus', 'importConfirm')
    ]}
  Counts.publish @, 'billManagers', Schema.orders.find(billQuery)

  orderFinishQuery =
    merchant    : merchantId
    orderType   : Enums.getValue('OrderTypes', 'success')
    orderStatus : Enums.getValue('OrderStatus', 'finish')
  Counts.publish @, 'orderManagers', Schema.orders.find(orderFinishQuery)

  # Giao dien hien thi cho Nhan vien
  Counts.publish @, 'customerOfStaff', Schema.customers.find({staff: @userId, merchant: merchantId})

  orderQuery.creator = @userId
  Counts.publish @, 'orderOfStaff', Schema.orders.find(orderQuery)

  billQuery.creator = @userId
  Counts.publish @, 'billManagerOfStaff', Schema.orders.find(billQuery)

  orderFinishQuery.creator = @userId
  Counts.publish @, 'orderHistoryOfStaff', Schema.orders.find(orderFinishQuery)

  customerGroupQuery = merchant: merchantId, customers: {$in: myProfile.customers ? []}
  Counts.publish @, 'customerGroupOfStaff', Schema.customerGroups.find(customerGroupQuery)

  Counts.publish @, 'customerReturnHistories', Schema.returns.find(
    creator     : @userId
    merchant    : merchantId
    returnType  : Enums.getValue('ReturnTypes', 'customer')
    returnStatus: Enums.getValue('ReturnStatus', 'initialize')
  )
  Counts.publish @, 'providerReturnHistories', Schema.returns.find(
    creator     : @userId
    merchant    : merchantId
    returnType  : Enums.getValue('ReturnTypes', 'provider')
    returnStatus: Enums.getValue('ReturnStatus', 'initialize')
  )

  return