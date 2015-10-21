simpleSchema.providers = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  nameSearch  : simpleSchema.searchSource('name')
  description : simpleSchema.OptionalString

  phone          : simpleSchema.OptionalString
  address        : simpleSchema.OptionalString
  billNo         : type: Number, defaultValue: 0
  representative : simpleSchema.OptionalString
  manufacturer   : simpleSchema.OptionalString

  saleBillNo        : type: Number, defaultValue: 0 #số phiếu bán
  importBillNo      : type: Number, defaultValue: 0 #số phiếu nhap
  returnBillNo      : type: Number, defaultValue: 0 #số phiếu tra hang
  transactionBillNo : type: Number, defaultValue: 0 #số phiếu thu chi

  debtRequiredCash : type: Number, defaultValue: 0 #số nợ bắt buộc phải thu
  paidRequiredCash : type: Number, defaultValue: 0 #số nợ bắt buộc đã trả

  debtBeginCash    : type: Number, defaultValue: 0 #số nợ đầu kỳ phải thu
  paidBeginCash    : type: Number, defaultValue: 0 #số nợ đầu kỳ đã trả

  debtIncurredCash : type: Number, defaultValue: 0 #chi phí phát sinh cộng
  paidIncurredCash : type: Number, defaultValue: 0 #chi phí phát sinh trừ

  debtSaleCash     : type: Number, defaultValue: 0 #số tiền bán hàng phát sinh trong kỳ
  paidSaleCash     : type: Number, defaultValue: 0 #số tiền đã trả phát sinh trong kỳ
  returnSaleCash   : type: Number, defaultValue: 0 #số tiền trả hàng phát sinh trong kỳ

  merchant    : simpleSchema.DefaultMerchant
  avatar      : simpleSchema.OptionalString
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator
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
    doc.hasAvatar = -> if doc.avatar then '' else 'missing'
    doc.avatarUrl = -> if doc.avatar then AvatarImages.findOne(doc.avatar)?.url() else undefined
    doc.remove    = -> Schema.providers.remove(@_id) if @allowDelete

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
