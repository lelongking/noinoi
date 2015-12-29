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
