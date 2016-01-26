Enums = Apps.Merchant.Enums

Wings.defineHyper 'customerManagementSalesHistorySection',
  helpers:
    transactions: ->
      transactions = []
      if customer = Template.currentData()
        transaction = Schema.transactions.find(
          owner: customer._id
          isPaidDirect: {$ne: true}
        )

        beforeDebtCash = (customer.initialAmount ? 0)

        transactions = _.sortBy transaction.fetch(), (item) ->
          item.sumBeforeBalance = beforeDebtCash + item.balanceBefore
          item.sumLatestBalance = beforeDebtCash + item.balanceLatest


          if item.isRoot
            if item.balanceType is Enums.getValue('TransactionTypes', 'saleAmount')
              parentFound = Schema.orders.findOne({
                _id        : item.parent
                buyer      : item.owner
                orderType  : Enums.getValue('OrderTypes', 'success')
                orderStatus: Enums.getValue('OrderStatus', 'finish')
              })
              if parentFound
                item.sumLatestBalance = item.sumBeforeBalance + (parentFound.finalPrice - parentFound.depositCash)
            else if item.balanceType is Enums.getValue('TransactionTypes', 'returnSaleAmount')
              parentFound = Schema.returns.findOne({
                _id         : item.parent
                owner       : item.owner
                returnType  : Enums.getValue('ReturnTypes', 'customer')
                returnStatus: Enums.getValue('ReturnStatus', 'success')
              })
              if parentFound
                item.sumLatestBalance = item.sumBeforeBalance - (parentFound.finalPrice - parentFound.depositCash)

            if parentFound
              item.parentFound      = parentFound
              item.balanceChange    = Math.abs(parentFound.finalPrice - parentFound.depositCash)
              item.description      = '(' + item.description + ')' if item.description


          item.billNo =
            if parentFound?.model is 'orders'
              'Phiếu ' + parentFound.billNoOfBuyer
            else if parentFound?.model is 'returns'
              'Trả hàng theo phiếu ' + parentFound.returnCode

          item.successDate =
            if parentFound
              parentFound.successDate
            else
              item.version.createdAt

          item.successDate

      transactions

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
      trackingDate and @allowDelete

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