simpleSchema.merchants = new SimpleSchema
  name    : type: String, optional: true
  address : type: String, optional: true
  phone   : type: String, optional: true
  email   : type: String, optional: true
  logo    : type: String, optional: true
  version : type: simpleSchema.Version

  customerCodes    : type: [String], defaultValue: []
  customerPhones   : type: [String], defaultValue: []
  providerCodes    : type: [String], defaultValue: []
  productCodes     : type: [String], defaultValue: []

  importCodes      : type: [String], defaultValue: []
  orderCodes       : type: [String], defaultValue: []
  returnCodes      : type: [String], defaultValue: []
  transactionCodes : type: [String], defaultValue: []


  saleBillNo        : type: Number, defaultValue: 0 #số phiếu bán
  importBillNo      : type: Number, defaultValue: 0 #số phiếu nhap
  returnBillNo      : type: Number, defaultValue: 0 #số phiếu tra hang
  transactionBillNo : type: Number, defaultValue: 0 #số phiếu thu chi

  warehouses                 : type: [Object]
  "warehouses.$._id"         : simpleSchema.UniqueId
  "warehouses.$.createdAt"   : simpleSchema.DefaultCreatedAt
  "warehouses.$.isRoot"      : simpleSchema.DefaultBoolean(false)
  "warehouses.$.name"        : type: String
  "warehouses.$.description" : type: String, optional: true
  "warehouses.$.address"     : type: String, optional: true
  "warehouses.$.phone"       : type: String, optional: true

  options                         : type: Object, optional: true
  'options.deliveryLateDay'       : type: Number, optional: true
  'options.orderDeleteInDay'      : type: Number, optional: true
  'options.transactionDeleteInDay': type: Number, optional: true
  'options.returnDeleteInDay'     : type: Number, optional: true
  'options.dueDay'                : type: Number, optional: true
  'options.showInventory'         : type: Boolean, optional: true
  'options.autoConfirm'           : type: Boolean, optional: true


  merchantSummaries               : type: Object  , optional    : true
  "merchantSummaries.barcodeUsed" : type: [String], defaultValue: []

Schema.add 'merchants', "Merchant", class Merchant
  @getId: ->
    Meteor.users.findOne(Meteor.userId())?.profile.merchant