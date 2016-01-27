Enums = Apps.Merchant.Enums

Wings.defineHyper 'providerDetailSection',
  helpers:
    transactions: ->
      transactions = []
      if provider = Template.currentData()
        transaction = Schema.transactions.find(
          owner: provider._id
          isPaidDirect: {$ne: true}
        )

        beforeDebtCash = (provider.initialAmount ? 0)

        transactions = _.sortBy transaction.fetch(), (item) ->
          item.sumBeforeBalance = beforeDebtCash + item.balanceBefore
          item.sumLatestBalance = beforeDebtCash + item.balanceLatest


          if item.isRoot
            if item.balanceType is Enums.getValue('TransactionTypes', 'importAmount')
              parentFound = Schema.imports.findOne({
                _id        : item.parent
                provider   : item.owner
                importType : Enums.getValue('ImportTypes', 'success')
              })
              if parentFound
                item.sumLatestBalance = item.sumBeforeBalance + (parentFound.finalPrice - parentFound.depositCash)
            else if item.balanceType is Enums.getValue('TransactionTypes', 'returnImportAmount')
              parentFound = Schema.returns.findOne({
                _id         : item.parent
                owner       : item.owner
                returnType  : Enums.getValue('ReturnTypes', 'provider')
                returnStatus: Enums.getValue('ReturnStatus', 'success')
              })
              if parentFound
                item.sumLatestBalance = item.sumBeforeBalance - (parentFound.finalPrice - parentFound.depositCash)

            if parentFound
              item.parentFound      = parentFound
              item.balanceChange    = Math.abs(parentFound.finalPrice - parentFound.depositCash)
              item.description      = '(' + item.description + ')' if item.description


          item.billNo =
            if parentFound?.model is 'imports'
              'Phiếu ' + parentFound.billNoOfProvider
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

    isDelete: ->
      trackingDate   = moment().diff(@version.createdAt ? new Date(), 'days') < 1
      trackingDelete = if @isRoot then @parentFound?.allowDelete else @allowDelete
      trackingDate and trackingDelete

  events:
    "click .deleteTransaction": (event, template) ->
      console.log @
      if @isRoot
        if @balanceType is Enums.getValue('TransactionTypes', 'returnImportAmount')
          Meteor.call('deleteReturn', @parent, @owner, Enums.getValue('ReturnTypes', 'provider')) if @parent

        else if @balanceType is Enums.getValue('TransactionTypes', 'importAmount')
          Meteor.call('deleteImport', @parent) if @parent
      else
        Meteor.call('deleteTransaction', @_id)
      event.stopPropagation()