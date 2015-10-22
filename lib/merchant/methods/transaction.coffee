Enums = Apps.Merchant.Enums
findTransactionParent = (transaction)->
  if transaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
    parent = Schema.imports.findOne(transaction.parent)
  else if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
    parent = Schema.orders.findOne(transaction.parent)
  else
    parent = Schema.returns.findOne(transaction.parent)
  parent


Meteor.methods
  addCustomer:(name, description) -> Schema.customers.insert({name: name})

  createTransaction: (ownerId, money, name = null, description = null, transactionGroup = Enums.getValue('TransactionGroups', 'provider'), receivable = undefined)->
    console.log ownerId, money, name, description, transactionGroup, receivable


    if transactionGroup is Enums.getValue('TransactionGroups', 'provider')
      owner = Schema.providers.findOne(ownerId)
    #    else if transactionType is Enums.getValue('TransactionGroups', 'customer')
    #      owner = Schema.customers.findOne(ownerId)

    if owner
      transaction = Schema.transactions.findOne({owner: owner._id}, {sort: {'version.createdAt': -1}})

      ownerUpdate = $set: {allowDelete : false}, $inc:{}
      ownerUpdate.$inc.totalCash = if receivable then money else -money
      if transaction # tao phieu tra tien, no cu. ko co tao phieu ban voi tra hang
        ownerUpdate.$inc.paidCash  = if receivable then 0 else money
        ownerUpdate.$inc.loanCash  = if receivable then money else 0
      else #Nhap ton dau ky
        ownerUpdate.$inc.beginCash = if receivable then money else -money

      transactionInsert =
#      transactionCode :
        transactionGroup  : transactionGroup
        transactionType : Enums.getValue('TransactionTypes', 'incurredCash')
        owner             : owner._id
        receivable        : receivable
        beforeDebtBalance : owner.totalCash
        owedCash          : money
        status            : Enums.getValue('TransactionStatuses', if receivable then 'tracking' else 'closed')

      transactionInsert.transactionName = name if name
      transactionInsert.description = description if description
      transactionInsert.parent = transaction.parent if transaction?.parent
      transactionInsert.isBeginCash = if transaction then false else true
      transactionInsert.isUseCode = !transactionInsert.isBeginCash

      if transactionGroup is Enums.getValue('TransactionGroups', 'provider')
        transactionInsert.transactionName   = if receivable then 'Phiếu Thu' else 'Phiếu Chi'
        unless description
          transactionInsert.description     = if receivable then 'Nợ tiền' else 'Trả tiền'
        transactionInsert.debtBalanceChange = if receivable then money else 0
        transactionInsert.paidBalanceChange = if receivable then 0 else money

      #      else if transactionType is Enums.getValue('TransactionTypes', 'customer')
      #        transactionInsert.transactionName   = if receivable then 'Phiếu Chi' else 'Phiếu Thu'
      #        unless description
      #          transactionInsert.description     = if receivable then 'Nợ tiền' else 'Trả tiền'
      #        transactionInsert.debtBalanceChange = if receivable then money else 0
      #        transactionInsert.paidBalanceChange = if receivable then 0 else money

      latestDebtBalance = transactionInsert.beforeDebtBalance + ownerUpdate.$inc.totalCash
      transactionInsert.latestDebtBalance = latestDebtBalance

      if Schema.transactions.insert(transactionInsert)
        if transactionGroup is Enums.getValue('TransactionGroups', 'provider')
          Schema.providers.update owner._id, ownerUpdate
#        else if transactionType is Enums.getValue('TransactionGroups', 'customer')
#          Schema.customers.update owner._id, ownerUpdate
#          Schema.customerGroups.update owner.group, $inc:{totalCash: ownerUpdate.$inc.totalCash} if owner.group

  createNewTransaction: (transactionGroup, transactionType, receivable, ownerId, money, description = null)->
#    console.log ownerId, money, description, transactionType, receivable
    if money < 0
      console.log('transaction Money > 0'); return

    if transactionGroup is Enums.getValue('TransactionGroups', 'customer')
      if owner = Schema.customers.findOne(ownerId)
        transactionInsert =
          transactionType   : transactionType
          transactionGroup  : transactionGroup
          owner             : owner._id
          receivable        : receivable
          balanceChange     : money
          description       : description
          status            : Enums.getValue('TransactionStatuses', if receivable then 'tracking' else 'closed')

          changeBalance     :
            paidRequiredCash: 0
            paidBeginCash   : 0
            debtIncurredCash: 0
            paidIncurredCash: 0
            debtSaleCash    : 0
            paidSaleCash    : 0
            returnSaleCash  : 0

        changeBalance = transactionInsert.changeBalance
        if receivable #receivable is True(Debt) là nợ: Phát sinh khác, Bán Hàng
          if transactionType is Enums.getValue('TransactionTypes', 'incurredCash') #Phát sinh cộng
            transactionInsert.transactionName = 'Phát Sinh Cộng'
            transactionInsert.description     = 'Phát sinh cộng'
            changeBalance.debtIncurredCash   += transactionInsert.balanceChange


          else if transactionType is Enums.getValue('TransactionTypes', 'saleCash') #Bán Hàng
            transactionInsert.transactionName = 'Bán Hàng'
            transactionInsert.description     = 'Bán hàng'
            changeBalance.debtSaleCash       += transactionInsert.balanceChange

        else #receivable is False(Paid) là trả nợ: Nợ Phải Thu, Nợ Đầu Kỳ, Phát Sinh Khác, Bán Hàng, Trả Hàng
          if transactionType is Enums.getValue('TransactionTypes', 'requiredCash') #Trả Nợ - Nợ Phải Thu
            transactionInsert.transactionName = 'Thu Nợ Phải Thu'
            transactionInsert.description     = 'Thu nợ phải thu'
            changeBalance.paidRequiredCash   += transactionInsert.balanceChange

          else if transactionType is Enums.getValue('TransactionTypes', 'beginCash') #Trả Nợ - Nợ Đầu Kỳ
            transactionInsert.transactionName = 'Thu Nợ Đầu Kỳ'
            transactionInsert.description     = 'Thu nợ đầu kỳ'
            changeBalance.paidBeginCash      += transactionInsert.balanceChange

          else if transactionType is Enums.getValue('TransactionTypes', 'incurredCash') #Phát Sinh Trừ - Phieu Thu
            transactionInsert.transactionName = 'Phát Sinh Trừ'
            transactionInsert.description     = 'Phát sinh trừ'
            changeBalance.paidIncurredCash   += transactionInsert.balanceChange

          else if transactionType is Enums.getValue('TransactionTypes', 'saleCash') #Trả Nợ - Bán Hàng
            transactionInsert.transactionName = 'Trả Tiền'
            transactionInsert.description     = 'Trả tiền'
            changeBalance.paidSaleCash       += transactionInsert.balanceChange

          else if transactionType is Enums.getValue('TransactionTypes', 'returnCash') #Trả Hàng
            transactionInsert.transactionName = 'Trả Hàng'
            transactionInsert.description     = 'Trả hàng'
            changeBalance.returnSaleCash     += transactionInsert.balanceChange


        transactionInsert.description = description if description
        latestTransaction = Schema.transactions.findOne({transactionGroup: transactionGroup, owner: owner._id}, {sort: {'version.createdAt': -1}})
        transactionInsert.parent = latestTransaction.parent if latestTransaction?.parent

        Schema.transactions.insert(transactionInsert) if transactionInsert.transactionName


    else if transactionGroup is Enums.getValue('TransactionGroups', 'provider')
      owner = Schema.providers.findOne(ownerId)

  deleteNewTransaction: (transactionId) ->
    if transaction = Schema.transactions.findOne({
      $and : [
        _id               : transactionId
      ,
        merchant          : Merchant.getId()
      ,
        transactionGroup  : Enums.getValue('TransactionGroups', 'customer')
      ,
        $or: [
          transactionType: Enums.getValue('TransactionTypes', 'incurredCash')
        ,
          transactionType: Enums.getValue('TransactionTypes', 'requiredCash')
          receivable     : false
        ,
          transactionType: Enums.getValue('TransactionTypes', 'beginCash')
          receivable     : false
        ,
          transactionType: Enums.getValue('TransactionTypes', 'saleCash')
          receivable     : false
        ]
      ]
    })
      Schema.transactions.remove(transaction._id)



# chi xoa transaction no dau ky, voi phieu tra tien, no cu, ko xoa dc phieu ban hang va tra hang
  deleteTransaction: (transactionId) ->
    if transaction = Schema.transactions.findOne({_id: transactionId, transactionGroup: Enums.getValue('TransactionGroups', 'provider')})
      if Schema.transactions.remove(transaction._id)
        if transaction.parent
          beforeTransactionQuery =
            owner              : transaction.owner
            isRoot             : true
            'version.createdAt': {$lt: transaction.version.createdAt}
          findBeforeTransaction = Schema.transactions.findOne(beforeTransactionQuery)

        latestDebtBalance = 0; beforeDebtBalance = transaction.beforeDebtBalance
        transactionQuery  = {owner: transaction.owner, 'version.createdAt': {$gt: transaction.version.createdAt}}
        Schema.transactions.find(transactionQuery, {sort: {'version.createdAt': 1}}).forEach(
          (item) ->
            if item.transactionGroup is Enums.getValue('TransactionGroups', 'provider')
              latestDebtBalance = beforeDebtBalance + item.debtBalanceChange - item.paidBalanceChange
            #            else if item.transactionGroup is Enums.getValue('TransactionGroups', 'customer')
            #              latestDebtBalance = beforeDebtBalance + item.debtBalanceChange - item.paidBalanceChange

            transactionUpdate = $set:{beforeDebtBalance: beforeDebtBalance, latestDebtBalance: latestDebtBalance}
            if transaction.parent and transaction.isRoot and transaction.parent is item.parent
              if findBeforeTransaction
                transactionUpdate.$set.parent = findBeforeTransaction.parent
              else
                transactionUpdate.$unset = {parent: ""}

            Schema.transactions.update item._id, transactionUpdate
            beforeDebtBalance = latestDebtBalance
        )

        updateAllowDelete = {allowDelete: false}
        updateAllowDelete.allowDelete = true if Schema.transactions.find({owner: transaction.owner}).count() is 0

        if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'provider')
          if transaction.isBeginCash #no ton day ky
            updateOwner =
              beginCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
              totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
          else
            updateOwner =
              paidCash   : -transaction.paidBalanceChange
              loanCash   : -transaction.debtBalanceChange
              totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
          Schema.providers.update(transaction.owner, {$inc: updateOwner, $set: updateAllowDelete})

#        else if transaction.transactionGroup is Enums.getValue('TransactionGroups', 'customer')
#          if transaction.isBeginCash #no ton day ky
#            updateOwner =
#              beginCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
#              totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
#          else
#            updateOwner =
#              paidCash   : -transaction.paidBalanceChange
#              loanCash   : -transaction.debtBalanceChange
#              totalCash  : transaction.paidBalanceChange - transaction.debtBalanceChange
#          Schema.customers.update(transaction.owner, {$inc: updateOwner, $set: updateAllowDelete})
#
#          if customer = Schema.customers.findOne(transaction.owner)
#            Schema.customerGroups.update customer.group, $inc:{totalCash: updateOwner.totalCash} if customer.group
