Enums = Apps.Merchant.Enums
simpleSchema.customers = new SimpleSchema
#----Required Information-------------------------------
  name  : type: String, index: 1
  code  : type: String, index: 1, optional: true
  phone : type: String, index: 1, optional: true

#----Important Information-------------------------------
  address  : type: String, optional: true
  location : type: String, optional: true
  avatar   : type: String, optional: true

#----Debt information--------------------------------------------------------------
  debtRequiredCash : type: Number, optional: true #số nợ bắt buộc phải thu
  paidRequiredCash : type: Number, optional: true #số nợ bắt buộc đã trả

  debtBeginCash    : type: Number, optional: true #số nợ đầu kỳ phải thu
  paidBeginCash    : type: Number, optional: true #số nợ đầu kỳ đã trả

  debtIncurredCash : type: Number, optional: true #chi phí phát sinh cộng
  paidIncurredCash : type: Number, optional: true #chi phí phát sinh trừ

  debtSaleCash     : type: Number, optional: true #số tiền bán hàng phát sinh trong kỳ
  paidSaleCash     : type: Number, optional: true #số tiền đã trả phát sinh trong kỳ
  returnSaleCash   : type: Number, optional: true #số tiền trả hàng phát sinh trong kỳ





  saleInterestRate    : type: Number, optional: true, decimal: true


  initialAmount       : type: Number, optional: true #no ban dau
  initialInterestRate : type: Number, optional: true, decimal: true
  initialStartDate    : type: Date  , optional: true

  saleAmount          : type: Number, defaultValue: 0 #ban hang
  returnAmount        : type: Number, defaultValue: 0 #tra hàng(tru va ban hang)
  loanAmount          : type: Number, defaultValue: 0 #no cho vay(muon)
  returnPaidAmount    : type: Number, defaultValue: 0 #no trả hàng(tra hang lay tien mat)
  paidAmount          : type: Number, defaultValue: 0 #no đã trả(khách hàng tra tien)
  interestAmount      : type: Number, defaultValue: 0 #no cho vay(tien lai)



#----Detailed Interest--------------------------------
  debtDetails               : type: Object, optional: true
  'debtDetails.seasonId'    : type: String, optional: true
  'debtDetails.debtType'    : type: Number, optional: true

  'debtDetails.parent'      : type: String, optional: true
  'debtDetails.detailId'    : type: String, optional: true

  'debtDetails.amount'      : type: Number, optional: true
  'debtDetails.interestRate': type: Number, optional: true, decimal: true
  'debtDetails.startDate'   : type: Date  , optional: true
  'debtDetails.endDate'     : type: Date  , optional: true

#----Detailed information--------------------------------
  deliveryCompany        : type: String, optional: true
  deliveryAddress        : type: String, optional: true

  profiles               : type: Object, optional: true
  'profiles.gender'      : simpleSchema.DefaultBoolean()
  'profiles.description' : type: String, optional: true
  'profiles.phone'       : type: String, optional: true
  'profiles.address'     : type: String, optional: true
  'profiles.areas'       : type: String, optional: true

  'profiles.dateOfBirth' : type: String, optional: true
  'profiles.pronoun'     : type: String, optional: true
  'profiles.companyName' : type: String, optional: true
  'profiles.email'       : type: String, optional: true

#----System Information-------------------------------
  customerCode      : type: String, optional: true
  customerOfGroup   : type: String, optional: true
  customerOfStaff   : type: String, optional: true

  merchant          : type: String, optional: true
  creator           : type: String, optional: true
  allowDelete       : type: Boolean, optional: true
  version           : { type: simpleSchema.Version }

#----Automatic Information-------------------------------
  nameSearch        : type: String, index: 1, optional: true
  firstName         : type: String, optional: true
  lastName          : type: String, optional: true

  orderWaiting      : type: [String], optional: true
  orderFailure      : type: [String], optional: true
  orderSuccess      : type: [String], optional: true

  saleBillNo        : type: Number, defaultValue: 0 #số phiếu bán
  importBillNo      : type: Number, defaultValue: 0 #số phiếu nhap
  returnBillNo      : type: Number, defaultValue: 0 #số phiếu tra hang
  transactionBillNo : type: Number, defaultValue: 0 #số phiếu thu chi









Schema.add 'customers', "Customer", class Customer
  @transform: (doc) ->
    doc.orderWaitingCount = -> if @orderWaiting then @orderWaiting.length else 0
    doc.orderFailureCount = -> if @orderFailure then @orderFailure.length else 0
    doc.orderSuccessCount = -> if @orderSuccess then @orderSuccess.length else 0

    doc.hasAvatar = -> if @avatar then '' else 'missing'
    doc.avatarUrl = -> if @avatar then AvatarImages.findOne(@avatar)?.url() else undefined


    saleCash         = (doc.saleAmount ? 0) + (doc.returnPaidAmount ? 0) - (doc.returnAmount ? 0)
    doc.initialCash    = (doc.initialAmount ? 0)
    doc.debitCash      = saleCash + (doc.loanAmount ? 0)
    doc.interestCash   = (doc.interestAmount ? 0)
    doc.paidCash       = (doc.paidAmount ? 0)
    doc.totalDebitCash = (doc.initialAmount ? 0) + doc.debitCash
    doc.totalCash      = doc.totalDebitCash + doc.interestCash - doc.paidCash

    doc.remove = ->
      if doc.saleAmount > 0 and doc.returnAmount > 0 and doc.loanAmount > 0 and doc.returnPaidAmount > 0 and doc.paidAmount > 0 and doc.interestAmount > 0
        Schema.customers.update(doc._id, $set:{allowDelete: false}) if doc.allowDelete
      else
        orderCursor  = Schema.orders.find(
          buyer       : doc._id
          orderStatus : { $ne: Enums.getValue('OrderStatus', 'initialize') }
        )
        returnCursor = Schema.returns.find(
          owner       : doc._id
          returnType  : Enums.getValue('ReturnTypes', 'customer')
          returnStatus: Enums.getValue('ReturnStatus', 'success')
        )
        if orderCursor.count() > 0 or returnCursor.count() > 0
          Schema.customers.update(doc._id, $set:{allowDelete: false}) if doc.allowDelete
        else
          Schema.customers.remove(@_id)
          randomGetCustomerId = Schema.customers.findOne({merchant: doc.merchant})?._id
          @setCustomerSession(randomGetCustomerId ? '')



  @insert: (name, description) ->
    insertOption = {name: name}
    insertOption.description = description if description
    customerId = Schema.customers.insert insertOption

  @splitName: (fullText) ->
    if fullText.indexOf("(") > 0
      namePart        = fullText.substr(0, fullText.indexOf("(")).trim()
      descriptionPart = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
      return { name: namePart, description: descriptionPart }
    else
      return { name: fullText }

  @nameIsExisted: (name, merchant) ->
    existedQuery = {name: name, merchant: merchant}
    Schema.customers.findOne(existedQuery)

  @setCustomerSession: (customerId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': customerId}})

  @setSession: (customerId) ->
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': customerId}})

  @updateCustomer: ->
    Schema.customers.find({}).forEach(
      (customer)->
        console.log customer
        Schema.customers.update(customer._id, { $set: {name: customer.name} })
    )

  @updateGroup: ->
    if defaultGroup = Schema.customerGroups.findOne({isBase: true})
      listCustomerIds = []
      Schema.customers.find({}).forEach(
        (customer)->
          Schema.customers.update(customer._id, { $set:{ group: defaultGroup._id } })
          listCustomerIds.push(customer._id)
      )
      if Schema.customerGroups.update(defaultGroup._id, $set:{customers: []})
        Schema.customerGroups.update(defaultGroup._id, $set:{customers: listCustomerIds})



