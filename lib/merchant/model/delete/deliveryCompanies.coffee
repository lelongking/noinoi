Enums = Apps.Merchant.Enums

simpleSchema.deliveryCompanies = new SimpleSchema
  name    : type: String, index: 1
  avatar  : type: String, optional: true
  address : type: String, optional: true
  phone   : type: String, optional: true
  email   : type: String, optional: true

  customerLists : type: [String], defaultValue: []

  nameSearch  : simpleSchema.searchSource('name')
  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator('creator')
  version     : type: simpleSchema.Version

  contacts: type: Object, optional: true
  'contacts.contactName'    : simpleSchema.OptionalString
  'contacts.contactAddress' : simpleSchema.OptionalString
  'contacts.contactPhone'   : simpleSchema.OptionalString
  'contacts.contactEmail'   : simpleSchema.OptionalString

Schema.add 'deliveryCompanies', "DeliveryCompany", class DeliveryCompany
  @insideMerchant: (merchantId) -> @schema.find({parentMerchant: merchantId})
  @insideBranch: (branchId) -> @schema.find({merchant: branchId})