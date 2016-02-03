Enums = Apps.Merchant.Enums
simpleSchema.providers = new SimpleSchema
  name  : type: String, index: 1
  code  : type: String, index: 1, optional: true
  phone : type: String, index: 1, optional: true

  nameSearch: type: String, index: 1, optional: true
  firstName : type: String, optional: true
  lastName  : type: String, optional: true

  avatar    : type: String, optional: true
  description : simpleSchema.OptionalString

  address        : simpleSchema.OptionalString
  billNo         : type: Number, defaultValue: 0
  representative : simpleSchema.OptionalString #nguoi dai dien
  manufacturer   : simpleSchema.OptionalString

  saleBillNo        : type: Number, defaultValue: 0 #số phiếu bán
  importBillNo      : type: Number, defaultValue: 0 #số phiếu nhap
  returnBillNo      : type: Number, defaultValue: 0 #số phiếu tra hang
  transactionBillNo : type: Number, defaultValue: 0 #số phiếu thu chi

  initialAmount       : type: Number, optional: true #no ban dau
  initialInterestRate : type: Number, optional: true, decimal: true
  initialStartDate    : type: Date, optional: true

  importAmount      : type: Number, optional: true
  returnAmount      : type: Number, optional: true
  loanAmount        : type: Number, optional: true
  returnPaidAmount  : type: Number, optional: true
  paidAmount        : type: Number, optional: true
  interestAmount    : type: Number, optional: true

  merchant    : simpleSchema.DefaultMerchant
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator('creator')
  version     : { type: simpleSchema.Version }

  profiles               : type: Object, optional: true
  'profiles.phone'       : type: String, optional: true
  'profiles.address'     : type: String, optional: true
  'profiles.gender'      : simpleSchema.DefaultBoolean()
  'profiles.areas'       : type: [String], optional: true
  'profiles.description' : type: [String], optional: true

  'profiles.dateOfBirth' : type: String, optional: true
  'profiles.pronoun'     : type: String, optional: true
  'profiles.companyName' : type: String, optional: true
  'profiles.email'       : type: String, optional: true

Schema.add 'providers', "Provider", class Provider
  @transform: (doc) ->
    importCash         = (doc.importAmount ? 0) + (doc.returnPaidAmount ? 0) - (doc.returnAmount ? 0)
    doc.debitCash      = importCash + (doc.loanAmount ? 0)
    doc.interestCash   = (doc.interestAmount ? 0)
    doc.paidCash       = (doc.paidAmount ? 0)
    doc.totalDebitCash = (doc.initialAmount ? 0) + doc.debitCash
    doc.totalCash      = doc.totalDebitCash + doc.interestCash - doc.paidCash

    doc.hasAvatar = -> if doc.avatar then '' else 'missing'
    doc.avatarUrl = -> if doc.avatar then AvatarImages.findOne(doc.avatar)?.url() else undefined

    doc.remove    = ->
      if doc.importAmount > 0 or doc.returnAmount > 0 or doc.loanAmount > 0 or doc.returnPaidAmount > 0 or doc.paidAmount > 0 or doc.interestAmount > 0 or @initialAmount > 0
        Schema.providers.update(doc._id, $set:{allowDelete: false}) if doc.allowDelete
      else
        importCursor  = Schema.imports.find(
          provider   : doc._id
          importType : { $ne: Enums.getValue('ImportTypes', 'initialize') }
        )
        returnCursor = Schema.returns.find(
          owner       : doc._id
          returnType  : Enums.getValue('ReturnTypes', 'provider')
          returnStatus: Enums.getValue('ReturnStatus', 'success')
        )
        if importCursor.count() > 0 or returnCursor.count() > 0
          Schema.providers.update(doc._id, $set:{allowDelete: false}) if doc.allowDelete
        else
          Schema.providers.remove(@_id)
          randomGetProviderId = Schema.providers.findOne({merchant: doc.merchant})?._id
          Provider.selectProvider(randomGetProviderId ? '')




  @insert: (name, description, callback) ->
    Schema.providers.insert({name: name, description: description}, callback)

  @splitName: (fullText) ->
    if fullText.indexOf("(") > 0
      namePart        = fullText.substr(0, fullText.indexOf("(")).trim()
      descriptionPart = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()

      return { name: Helpers.ConvertNameUpperCase(namePart), description: descriptionPart }
    else
      return { name: Helpers.ConvertNameUpperCase(fullText) }

  @nameIsExisted: (name, merchant) ->
    existedQuery = {name: name, merchant: merchant}
    Schema.providers.findOne(existedQuery)

  @selectProvider: (providerId) ->
    if userId = Meteor.userId()
      Session.set "providerManagementShowEditCommand"
#      Meteor.subscribe('providerManagementCurrentProviderData', @providerId)
      Meteor.users.update(userId, {$set: {'sessions.currentProvider': providerId}})
