Enums = Apps.Merchant.Enums

simpleSchema.transactions = new SimpleSchema
  name        : type: String, defaultValue: 'ĐƠN HÀNG'
  code        : type: String, optional: true, index: 1
  owner       : type: String, optional: true, index: 1
  parent      : type: String, optional: true, index: 1
  description : type: String, optional: true

  receivable  : type: Boolean , defaultValue: true #
  isBeginCash : type: Boolean , defaultValue: false # transaction la no dau ky
  isUseCode   : type: Boolean , defaultValue: false # transaction co Ma Phieu
  isRoot      : type: Boolean , defaultValue: false # transaction cua order hoac import or return
  isPaidDirect: type: Boolean , defaultValue: false # transaction cua order hoac import or return

  balanceType   : type: Number, defaultValue: Enums.getValue('TransactionTypes', 'saleAmount')
  balanceBefore : type: Number, defaultValue: 0
  balanceChange : type: Number, defaultValue: 0
  balanceLatest : type: Number, defaultValue: 0

  merchant   : simpleSchema.DefaultMerchant
  allowDelete: simpleSchema.DefaultBoolean()
  creator    : simpleSchema.DefaultCreator('creator')
  version    : { type: simpleSchema.Version }

Schema.add 'transactions', "Transaction", class Transaction
  @transform: (doc) ->

  @reCalculate: ->
    reCalculateCustomer()
    reCalculateProvider()




reCalculateCustomer = ->
  Schema.customers.find().forEach(
    (customer) ->
      latestDebtBalance = 0; beforeDebtBalance = 0
      updateOwner =
        $set:
          loanAmount      : 0
          paidAmount      : 0
          saleAmount      : 0
          returnAmount    : 0
          returnPaidAmount: 0

      Schema.transactions.find(owner: customer._id, {sort: {'version.createdAt': 1}}).forEach(
        (item) ->
          if item.balanceType is Enums.getValue('TransactionTypes', 'saleAmount')
            latestDebtBalance                 += item.balanceChange
            updateOwner.$set.saleAmount       += item.balanceChange
          else if item.balanceType is Enums.getValue('TransactionTypes', 'customerLoanAmount')
            latestDebtBalance                 += item.balanceChange
            updateOwner.$set.loanAmount       += item.balanceChange
          else if item.balanceType is Enums.getValue('TransactionTypes', 'returnCustomerPaidAmount')
            latestDebtBalance                 += item.balanceChange
            updateOwner.$set.returnPaidAmount += item.balanceChange

          else if item.balanceType is Enums.getValue('TransactionTypes', 'returnSaleAmount')
            latestDebtBalance                 += -item.balanceChange
            updateOwner.$set.returnAmount     += item.balanceChange
          else if item.balanceType is Enums.getValue('TransactionTypes', 'customerPaidAmount')
            latestDebtBalance                 += -item.balanceChange
            updateOwner.$set.paidAmount       += item.balanceChange

          transactionUpdate = $set:{balanceBefore: beforeDebtBalance, balanceLatest: latestDebtBalance}
          Schema.transactions.update item._id, transactionUpdate
          beforeDebtBalance = latestDebtBalance
      )

      Schema.customers.update(customer._id, updateOwner)
  )

reCalculateProvider = ->
  Schema.providers.find().forEach(
    (provider) ->
      latestDebtBalance = 0; beforeDebtBalance = 0
      updateOwner =
        $set:
          loanAmount      : 0
          paidAmount      : 0
          importAmount    : 0
          returnAmount    : 0
          returnPaidAmount: 0

      Schema.transactions.find(owner: provider._id, {sort: {'version.createdAt': 1}}).forEach(
        (item) ->
          if item.balanceType is Enums.getValue('TransactionTypes', 'importAmount')
            latestDebtBalance                 += item.balanceChange
            updateOwner.$set.importAmount     += item.balanceChange
          else if item.balanceType is Enums.getValue('TransactionTypes', 'providerLoanAmount')
            latestDebtBalance                 += item.balanceChange
            updateOwner.$set.loanAmount       += item.balanceChange
          else if item.balanceType is Enums.getValue('TransactionTypes', 'returnProviderPaidAmount')
            latestDebtBalance                 += item.balanceChange
            updateOwner.$set.returnPaidAmount += item.balanceChange

          else if item.balanceType is Enums.getValue('TransactionTypes', 'returnImportAmount')
            latestDebtBalance                 += -item.balanceChange
            updateOwner.$set.returnAmount     += item.balanceChange
          else if item.balanceType is Enums.getValue('TransactionTypes', 'providerPaidAmount')
            latestDebtBalance                 += -item.balanceChange
            updateOwner.$set.paidAmount       += item.balanceChange

          transactionUpdate = $set:{balanceBefore: beforeDebtBalance, balanceLatest: latestDebtBalance}
          Schema.transactions.update item._id, transactionUpdate
          beforeDebtBalance = latestDebtBalance
      )

      Schema.providers.update(provider._id, updateOwner)
  )