Enums = Apps.Merchant.Enums

Wings.defineHyper 'interestRateCustomerDetail',
  helpers:
    orderLists: ->
      if customer = Template.currentData()
        Schema.orders.find
          buyer      : customer._id
          orderType  : Enums.getValue('OrderTypes', 'success')
          orderStatus: Enums.getValue('OrderStatus', 'finish')
        ,
          sort: {successDate: 1}



    detail: ->
      detail = @
      detail.totalPrice = detail.basicQuantity * detail.price

      if product = Schema.products.findOne({'units._id': detail.productUnit})
        productUnit = _.findWhere(product.units, {_id: detail.productUnit})
        detail.productName      = product.name
        detail.basicUnitName    = product.unitName()
        detail.productUnitName  = productUnit.name
        detail.isBase           = productUnit.isBase
        detail.productUnitPrice = detail.price * detail.conversion
      detail

    isColor: -> 'background-color: #fff'
#    isBase: -> @conversion is 1
    isDelete: ->
      trackingDate   = moment().diff(@version.createdAt ? new Date(), 'days') < 1
      trackingDelete = if @isRoot then @parentFound?.allowDelete else @allowDelete
      trackingDate and trackingDelete

    monthInterestRate: ->
      (@initialInterestRate ? 3)

    dayInterestRate: ->
      (@initialInterestRate ? 3)/30

    dayInterestRateCount: ->
      moment().endOf('days').diff(moment(@initialStartDate ? @successDate).startOf('days'), 'days')

    initialRateAmount: ->
      interestAmount = (@initialAmount ? @totalPrice)/100
      interestRate   = (@initialInterestRate ? 3)/30
      interestDay    = moment().endOf('days').diff(moment(@initialStartDate ? @successDate).startOf('days'), 'days')
      interestAmount * interestRate * interestDay

  events:
    "click .deleteTransaction": (event, template) ->
      if @isRoot
        if @balanceType is Enums.getValue('TransactionTypes', 'returnSaleAmount')
          Meteor.call('deleteReturn', @parent, @owner, Enums.getValue('ReturnTypes', 'customer')) if @parent

        else if @balanceType is Enums.getValue('TransactionTypes', 'saleAmount')
          Meteor.call('deleteOrder', @parent) if @parent
      else
        Meteor.call('deleteTransaction', @_id)
      event.stopPropagation()