simpleSchema.merchants = new SimpleSchema
  name    : type: String, optional: true
  phone   : type: String, optional: true
  address : type: String, optional: true
  email   : type: String, optional: true
  logo    : type: String, optional: true
  owner   : type: String, optional: true
  version : type: simpleSchema.Version

  status               : type: Object
  "status.verified"    : type: Boolean, defaultValue: false
  "status.createdAt"   : simpleSchema.DefaultCreatedAt

  branches                 : type: [Object]
  "branches.$._id"         : simpleSchema.UniqueId
  "branches.$.isRoot"      : simpleSchema.DefaultBoolean(false)
  "branches.$.name"        : type: String
  "branches.$.address"     : type: String, optional: true
  "branches.$.phone"       : type: String, optional: true
  "branches.$.createdAt"   : simpleSchema.DefaultCreatedAt


  interestRates           : type: Object, optional: true
  "interestRates.initial" : type: Number, decimal: true , defaultValue: 0
  "interestRates.sale"   : type: Number, decimal: true , defaultValue: 0
  "interestRates.loan"    : type: Number, decimal: true , defaultValue: 0


  summaries                        : type: Object
  "summaries.lastProductCode"      : type: Number   , defaultValue: 0
  "summaries.listProductCodes"     : type: [String] , defaultValue: []

  "summaries.lastProviderCode"     : type: Number   , defaultValue: 0
  "summaries.listProviderCodes"    : type: [String] , defaultValue: []

  "summaries.lastCustomerCode"     : type: Number   , defaultValue: 0
  "summaries.listCustomerCodes"    : type: [String] , defaultValue: []

  "summaries.lastCustomerPhone"    : type: Number   , defaultValue: 0
  "summaries.listCustomerPhones"   : type: [String] , defaultValue: []

  "summaries.lastImportCode"       : type: Number   , defaultValue: 0
  "summaries.listImportCodes"      : type: [String] , defaultValue: []

  "summaries.lastOrderCode"        : type: Number   , defaultValue: 0
  "summaries.listOrderCodes"       : type: [String] , defaultValue: []

  "summaries.lastReturnCode"       : type: Number   , defaultValue: 0
  "summaries.listReturnCodes"      : type: [String] , defaultValue: []

  "summaries.lastInventoryCode"    : type: Number   , defaultValue: 0
  "summaries.listInventoryCodes"   : type: [String] , defaultValue: []

  "summaries.lastTransactionCode"  : type: Number   , defaultValue: 0
  "summaries.listTransactionCodes" : type: [String] , defaultValue: []


  seasons               : type: Object  , optional: true
  "seasons._id"         : type: String  , optional: true
  "seasons.isUsed"      : type: Boolean , defaultValue: false
  "seasons.name"        : type: String  , optional: true
  "seasons.description" : type: String  , optional: true
  "seasons.startDate"   : type: Date    , optional: true
  "seasons.endDate"     : type: Date    , optional: true

#-------------------------------------------------------------------------------------------------------
  saleBillNo        : type: Number, defaultValue: 0 #số phiếu bán
  importBillNo      : type: Number, defaultValue: 0 #số phiếu nhap
  returnBillNo      : type: Number, defaultValue: 0 #số phiếu tra hang
  transactionBillNo : type: Number, defaultValue: 0 #số phiếu thu chi

  options                         : type: Object, optional: true
  'options.deliveryLateDay'       : type: Number, optional: true
  'options.orderDeleteInDay'      : type: Number, optional: true
  'options.transactionDeleteInDay': type: Number, optional: true
  'options.returnDeleteInDay'     : type: Number, optional: true
  'options.dueDay'                : type: Number, optional: true
  'options.showInventory'         : type: Boolean, optional: true
  'options.autoConfirm'           : type: Boolean, optional: true

  noteOptions                     : type: Object, defaultValue: {}
  'noteOptions.customerReceivable': type: String, optional: true, defaultValue: 'THU TIỀN'
  'noteOptions.customerPayable'   : type: String, optional: true, defaultValue: 'CHI TIỀN'
  'noteOptions.customerSale'      : type: String, optional: true
  'noteOptions.customerReturn'    : type: String, optional: true, defaultValue: 'TRẢ HÀNG'

  'noteOptions.providerReceivable': type: String, optional: true
  'noteOptions.providerPayable'   : type: String, optional: true, defaultValue: 'TRẢ TIỀN'
  'noteOptions.providerImport'    : type: String, optional: true
  'noteOptions.providerReturn'    : type: String, optional: true, defaultValue: 'TRẢ HÀNG'


Schema.add 'merchants', "Merchant", class Merchant
  @transform: (doc) ->
    warehouse.merchantId = doc._id for warehouse in doc.branches


  @getId: ->
    Meteor.users.findOne(Meteor.userId())?.profile?.merchant