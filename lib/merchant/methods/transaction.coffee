Enums = Apps.Merchant.Enums
Meteor.methods
  addCustomer:(name, description) -> Schema.customers.insert({name: name})

  createTransaction: (ownerId, transactionType, balanceChange, name = null, description = null)->
    userProfile = Meteor.users.findOne({_id: Meteor.userId()})?.profile
    merchant    = Schema.merchants.findOne({_id: userProfile.merchant}) if userProfile
    if merchant
      console.log transactionType, ownerId, balanceChange, name, description

      balanceChange = Math.abs(balanceChange)
      isCustomer = if transactionType is Enums.getValue('TransactionTypes', 'saleAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'returnSaleAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'customerLoanAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'customerPaidAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'returnCustomerPaidAmount')
          true

      isProvider = if transactionType is Enums.getValue('TransactionTypes', 'importAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'returnImportAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'providerLoanAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'providerPaidAmount') or
        transactionType is Enums.getValue('TransactionTypes', 'returnProviderPaidAmount')
          true

      console.log isCustomer, isProvider

      if isCustomer
        owner = Schema.customers.findOne({_id: ownerId})
      else if isProvider
        owner = Schema.providers.findOne({_id: ownerId})

      if owner and balanceChange > 0
        oldTransaction = Schema.transactions.findOne({owner: owner._id}, {sort: {'version.createdAt': -1}})
        transactionInsert =
          owner          : ownerId
          balanceType    : transactionType
          balanceChange  : balanceChange

        transactionInsert.transactionName = name if name
        transactionInsert.description = description if description
        transactionInsert.parent = oldTransaction.parent if oldTransaction?.parent
        transactionInsert.isBeginCash = if oldTransaction then false else true
        transactionInsert.isUseCode = !transactionInsert.isBeginCash

        ownerUpdate = $set: {allowDelete : false}
        if isCustomer
          debitCash = (owner.interestAmount ? 0) + (owner.saleAmount ? 0) + (owner.loanAmount ? 0) + (owner.returnPaidAmount ? 0)
          paidCash  = (owner.returnAmount ? 0) + (owner.paidAmount ? 0)
          transactionInsert.balanceBefore = debitCash - paidCash
          transactionInsert.balanceLatest = transactionInsert.balanceBefore

          if transactionType is Enums.getValue('TransactionTypes', 'saleAmount')
            ownerUpdate.$inc = {saleAmount : balanceChange}
            transactionInsert.balanceLatest += balanceChange
            transactionInsert.description = (merchant.noteOptions.customerSale ? '') if !transactionInsert.description
          else if transactionType is Enums.getValue('TransactionTypes', 'customerLoanAmount')
            ownerUpdate.$inc = {loanAmount : balanceChange}
            transactionInsert.balanceLatest += balanceChange
            transactionInsert.receivable     = true
            transactionInsert.description    = (merchant.noteOptions.customerPayable ? '') if !transactionInsert.description
          else if transactionType is Enums.getValue('TransactionTypes', 'returnCustomerPaidAmount')
            ownerUpdate.$inc = {returnPaidAmount : balanceChange}
            transactionInsert.balanceLatest += balanceChange
            transactionInsert.receivable     = true
            transactionInsert.description    = (merchant.noteOptions.customerPayable ? '') if !transactionInsert.description

          else if transactionType is Enums.getValue('TransactionTypes', 'customerPaidAmount')
            ownerUpdate.$inc = {paidAmount : balanceChange}
            transactionInsert.balanceLatest += -balanceChange
            transactionInsert.receivable     = false
            transactionInsert.description    = (merchant.noteOptions.customerReceivable ? '') if !transactionInsert.description
          else if transactionType is Enums.getValue('TransactionTypes', 'returnSaleAmount')
            ownerUpdate.$inc = {returnAmount : balanceChange}
            transactionInsert.balanceLatest += -balanceChange
            transactionInsert.receivable     = false
            transactionInsert.description    = (merchant.noteOptions.customerReturn ? '') if !transactionInsert.description

        else if isProvider
          debitCash = (owner.interestAmount ? 0) + (owner.importAmount ? 0) + (owner.loanAmount ? 0) + (owner.returnPaidAmount ? 0)
          paidCash  = (owner.returnAmount ? 0) + (owner.paidAmount ? 0)
          transactionInsert.balanceBefore = debitCash - paidCash
          transactionInsert.balanceLatest = transactionInsert.balanceBefore


          if transactionType is Enums.getValue('TransactionTypes', 'providerPaidAmount')
            ownerUpdate.$inc = {paidAmount : balanceChange}
            transactionInsert.balanceLatest += -balanceChange
            transactionInsert.receivable     = false
            transactionInsert.description    = (merchant.noteOptions.providerPayable ? '') if !transactionInsert.description


        console.log transactionInsert

        if transactionId = Schema.transactions.insert(transactionInsert)
          if isCustomer
            Schema.customers.update owner._id, ownerUpdate
          else if isProvider
            Schema.providers.update owner._id, ownerUpdate
        transactionId


  deleteTransaction: (transactionId) ->
    userProfile = Meteor.users.findOne({_id: Meteor.userId()})?.profile
    merchant    = Schema.merchants.findOne({_id: userProfile.merchant}) if userProfile
    transaction = Schema.transactions.findOne({_id: transactionId, merchant: merchant._id }) if merchant
    if transaction
      if Schema.transactions.remove(transaction._id)
        if transaction.parent
          beforeTransactionQuery =
            owner              : transaction.owner
            isRoot             : true
            'version.createdAt': {$lt: transaction.version.createdAt}
          findBeforeTransaction = Schema.transactions.findOne(beforeTransactionQuery)

        latestDebtBalance = 0; beforeDebtBalance = transaction.balanceBefore
        transactionQuery  = {owner: transaction.owner, 'version.createdAt': {$gt: transaction.version.createdAt}}
        Schema.transactions.find(transactionQuery, {sort: {'version.createdAt': 1}}).forEach(
          (item) ->
            if item.balanceType is Enums.getValue('TransactionTypes', 'saleAmount')
              latestDebtBalance += item.balanceChange
            else if item.balanceType is Enums.getValue('TransactionTypes', 'customerLoanAmount')
              latestDebtBalance += item.balanceChange
            else if item.balanceType is Enums.getValue('TransactionTypes', 'returnCustomerPaidAmount')
              latestDebtBalance += item.balanceChange

            else if item.balanceType is Enums.getValue('TransactionTypes', 'returnSaleAmount')
              latestDebtBalance += -item.balanceChange
            else if item.balanceType is Enums.getValue('TransactionTypes', 'customerPaidAmount')
              latestDebtBalance += -item.balanceChange


            else if item.balanceType is Enums.getValue('TransactionTypes', 'importAmount')
              latestDebtBalance += item.balanceChange
            else if item.balanceType is Enums.getValue('TransactionTypes', 'providerLoanAmount')
              latestDebtBalance += item.balanceChange
            else if item.balanceType is Enums.getValue('TransactionTypes', 'returnProviderPaidAmount')
              latestDebtBalance += item.balanceChange

            else if item.balanceType is Enums.getValue('TransactionTypes', 'providerPaidAmount')
              latestDebtBalance += -item.balanceChange
            else if item.balanceType is Enums.getValue('TransactionTypes', 'returnImportAmount')
              latestDebtBalance += -item.balanceChange

            transactionUpdate = $set:{balanceBefore: beforeDebtBalance, balanceLatest: latestDebtBalance}
            if transaction.parent and transaction.isRoot and transaction.parent is item.parent
              if findBeforeTransaction
                transactionUpdate.$set.parent = findBeforeTransaction.parent
              else
                transactionUpdate.$unset = {parent: ""}

            Schema.transactions.update item._id, transactionUpdate
            beforeDebtBalance = latestDebtBalance
        )



        updateOwner = $set: {allowDelete: Schema.transactions.find({owner: transaction.owner}).count() is 0}
        if transaction.balanceType is Enums.getValue('TransactionTypes', 'saleAmount')
          updateOwner.$inc = saleAmount: -transaction.balanceChange
          isCustomer = true
        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'customerLoanAmount')
          updateOwner.$inc = loanAmount: -transaction.balanceChange
          isCustomer = true
        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'returnCustomerPaidAmount')
          updateOwner.$inc = returnPaidAmount: -transaction.balanceChange
          isCustomer = true

        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'returnSaleAmount')
          updateOwner.$inc = returnAmount: -transaction.balanceChange
          isCustomer = true
        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'customerPaidAmount')
          updateOwner.$inc = paidAmount: -transaction.balanceChange
          isCustomer = true


        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'importAmount')
          updateOwner.$inc = importAmount: -transaction.balanceChange
          isProvider = true
        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'providerLoanAmount')
          updateOwner.$inc = loanAmount: -transaction.balanceChange
          isProvider = true
        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'returnProviderPaidAmount')
          updateOwner.$inc = returnPaidAmount: -transaction.balanceChange
          isProvider = true

        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'providerPaidAmount')
          updateOwner.$inc = paidAmount: -transaction.balanceChange
          isProvider = true
        else if transaction.balanceType is Enums.getValue('TransactionTypes', 'returnImportAmount')
          updateOwner.$inc = returnAmount: -transaction.balanceChange
          isProvider = true

        if isCustomer
          Schema.customers.update(transaction.owner, updateOwner)
        else if isProvider
          Schema.providers.update(transaction.owner, updateOwner)


























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



