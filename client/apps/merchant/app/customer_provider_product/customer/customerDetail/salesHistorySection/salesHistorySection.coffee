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

    hasInterestRate: ->
      console.log @
      details = @parentFound?.details ? []
      for detail in details
        (isInterestRate = true if detail.interestRate)
      if isInterestRate then '(lãi suất)' else ''


    isColor: -> 'background-color: #fff'
#    isBase: -> @conversion is 1
    isDelete: ->
      trackingDate   = moment().diff(@version.createdAt ? new Date(), 'days') < 1
      trackingDelete = if @isRoot then @parentFound?.allowDelete else @allowDelete
      trackingDate and trackingDelete

  events:
    "click a.toInterestRate": (event, template) ->
      FlowRouter.go('interestRate')
      Session.set('editInterestRateManager', false)
      Session.set('customerManagementIsShowCustomerDetail', false)
      Session.set('customerManagementIsEditMode', false)
      Session.set("customerManagementShowEditCommand", false)

    "click .deleteTransaction": (event, template) ->

      if @isRoot
        if @balanceType is Enums.getValue('TransactionTypes', 'returnSaleAmount')
          if @parent
            Meteor.call 'deleteReturn', @parent, @owner, Enums.getValue('ReturnTypes', 'customer'), (error, result) ->
              if error
                console.log error


        else if @balanceType is Enums.getValue('TransactionTypes', 'saleAmount')
          if @parent
            Meteor.call 'deleteOrder', @parent, (error, result) ->
              if error
                console.log error
      else
        Meteor.call 'deleteTransaction', @_id, (error, result) ->
          if error
            console.log error

      event.stopPropagation()