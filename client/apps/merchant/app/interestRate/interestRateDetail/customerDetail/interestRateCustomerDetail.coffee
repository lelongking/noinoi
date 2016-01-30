Enums = Apps.Merchant.Enums

Wings.defineHyper 'interestRateCustomerDetail',
  helpers:
    isColor: -> 'background-color: #fff'

    isDelete: ->
      trackingDate   = moment().diff(@version.createdAt ? new Date(), 'days') < 1
      trackingDelete = if @isRoot then @parentFound?.allowDelete else @allowDelete
      trackingDate and trackingDelete

    orderLists: ->
      if customer = Template.currentData()
        Schema.orders.find
          buyer                 : customer._id
          orderType             : Enums.getValue('OrderTypes', 'success')
          orderStatus           : Enums.getValue('OrderStatus', 'finish')
          'details.interestRate': true
        ,
          sort: {successDate: 1}

    order: ->
      @
      totalPrice = 0
      @billNo = 'Phiếu ' + @billNoOfBuyer
      for detail in @details
        if detail.interestRate
          detail.totalPrice = detail.basicQuantity * detail.price
          totalPrice       += detail.totalPrice

          if product = Schema.products.findOne({'units._id': detail.productUnit})
            productUnit = _.findWhere(product.units, {_id: detail.productUnit})
            detail.productName      = product.name
            detail.basicUnitName    = product.unitName()
            detail.productUnitName  = productUnit.name
            detail.isBase           = productUnit.isBase
            detail.productUnitPrice = detail.price * detail.conversion

      @totalPrice = totalPrice
      @

    dayInterestRate: ->
      interestRates = Session.get('merchant')?.interestRates
      customer      = Template.instance().data

      if @model is "orders"
        interestRate = if customer.saleInterestRate is undefined then (interestRates.sale ? 0) else customer.saleInterestRate
      else
        interestRate = if customer.initialInterestRate is undefined then (interestRates.initial ? 0) else customer.initialInterestRate
      interestRate/30

    dayInterestRateCount: ->
      moment().endOf('days').diff(moment(@initialStartDate ? @successDate).startOf('days'), 'days')

    initialRateAmount: ->
      interestRates = Session.get('merchant')?.interestRates
      customer      = Template.instance().data

      if @model is "orders"
        interestRate = if customer.saleInterestRate is undefined then (interestRates.sale ? 0) else customer.saleInterestRate
      else
        interestRate = if customer.initialInterestRate is undefined then (interestRates.initial ? 0) else customer.initialInterestRate

      interestAmount = (@initialAmount ? @totalPrice)/100
      interestRate   = interestRate/30
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