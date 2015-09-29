Enums = Apps.Merchant.Enums

Meteor.publishComposite 'getCustomerLists', ->
  self = @
  return {
    find: ->
      currentProfile = Meteor.users.findOne({_id: self.userId})?.profile
      return EmptyQueryResult if !currentProfile
      Schema.customers.find(
        merchant: currentProfile.merchant
      ,
        fields:
          name      : 1
          nameSearch: 1
          avatar    : 1
          totalCash : 1
      )
    children: [
      find: (customer) -> AvatarImages.find {_id: customer.avatar}
    ]
  }


Meteor.publishComposite 'getCustomerId', (customerId)->
  check(customerId, String)
  self = @
  return {
    find: ->
      currentProfile = Meteor.users.findOne({_id: self.userId})?.profile
      return EmptyQueryResult if !currentProfile
      Schema.customers.find(
        _id     : customerId
        merchant: currentProfile.merchant
      )
    children: [
      find: (customer) -> AvatarImages.find {_id: customer.avatar}
    ,
      find: (customer) ->
        Schema.orders.find
          buyer      : customer._id
          orderType  : Enums.getValue('OrderTypes', 'success')
          orderStatus: Enums.getValue('OrderStatus', 'finish')
    ,
      find: (customer) ->
        Schema.returns.find
          owner       : customer._id
          returnType  : Enums.getValue('ReturnTypes', 'customer')
          returnStatus: Enums.getValue('ReturnStatus', 'success')
    ,
      find: (customer) ->
        Schema.transactions.find
          owner : customer._id
    ]
  }

Meteor.publish 'getProductId', (productId)->
  check(productId, String)
  return [] if !@userId
  myProfile  = Meteor.users.findOne(@userId)?.profile
  merchantId = myProfile.merchant if myProfile
  return [] if !merchantId

  Schema.products.find
    _id     : productId
    merchant: merchantId