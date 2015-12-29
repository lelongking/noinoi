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


  initialAmount       : type: Number, optional: true #no ban dau
  initialInterestRate : type: Number, optional: true, decimal: true
  initialStartDate    : type: Date, optional: true

  saleAmount          : type: Number, optional: true #ban hang
  returnAmount        : type: Number, optional: true #tra hàng(tru va ban hang)
  loanAmount          : type: Number, optional: true #no cho vay(muon)
  returnPaidAmount    : type: Number, optional: true #no trả hàng(tra hang lay tien mat)
  paidAmount          : type: Number, optional: true #no đã trả(khách hàng tra tien)
  interestAmount      : type: Number, optional: true #no cho vay(tien lai)



#----Detailed Interest--------------------------------
  debtDetails               : type: Object, optional: true
  'debtDetails.seasonId'    : type: String, optional: true
  'debtDetails.parent'      : type: String, optional: true
  'debtDetails.detailId'    : type: String, optional: true
  'debtDetails.debtType'    : type: Number, optional: true
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

    doc.requiredCash  = -> (@debtRequiredCash ? 0) - (@paidRequiredCash ? 0)
    doc.beginCash     = -> (@debtBeginCash ? 0) - (@paidBeginCash ? 0)
    doc.incurredCash  = -> (@debtIncurredCash ? 0) - (@paidIncurredCash ? 0)
    doc.saleCash      = -> (@debtSaleCash ? 0) - (@paidSaleCash ? 0) - (@returnSaleCash ? 0)


    debitCash = (doc.interestAmount ? 0) + (doc.saleAmount ? 0) + (doc.loanAmount ? 0) + (doc.returnPaidAmount ? 0)
    paidCash  = (doc.returnAmount ? 0) + (doc.paidAmount ? 0)
    doc.totalDebtCash = debitCash - paidCash
    doc.totalCash     = debitCash - paidCash + (doc.initialAmount ? 0)

    doc.remove = ->
      if @allowDelete and Schema.customers.remove(@_id)
        randomGetCustomerId = Schema.customers.findOne({merchant: Merchant.getId()})?._id ? ''
        @setCustomerSession(randomGetCustomerId)


    doc.calculateBalance = ->
      customerUpdate = {paidCash: 0, returnCash: 0, totalCash: 0, loanCash: 0, beginCash: 0, debtCash: 0}
      Schema.transactions.find({owner: @_id}).forEach(
        (transaction) ->
          console.log transaction
          if transaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
            if transaction.parent
              customerUpdate.beginCash  += 0
              customerUpdate.debtCash   += transaction.debtBalanceChange
              customerUpdate.loanCash   += 0
              customerUpdate.paidCash   += transaction.paidBalanceChange
              customerUpdate.returnCash += 0

            else
              customerUpdate.beginCash  += transaction.debtBalanceChange - transaction.paidBalanceChange
              customerUpdate.debtCash   += 0
              customerUpdate.loanCash   += 0
              customerUpdate.paidCash   += 0
              customerUpdate.returnCash += 0

          if transaction.transactionType is Enums.getValue('TransactionTypes', 'return')
            customerUpdate.beginCash  += 0
            customerUpdate.debtCash   += 0
            customerUpdate.loanCash   += 0
            customerUpdate.paidCash   += 0
            customerUpdate.returnCash += transaction.paidBalanceChange
      )
      customerUpdate.totalCash = customerUpdate.beginCash + customerUpdate.debtCash + customerUpdate.loanCash - customerUpdate.paidCash - customerUpdate.returnCash
      console.log customerUpdate
      Schema.customers.update @_id, $set: customerUpdate

  @calculate: ->
    Schema.customers.find({}).forEach(
      (customer) ->
        Schema.customers.update customer._id,
          $set:
            debtRequiredCash: 0
            paidRequiredCash: 0
            debtBeginCash   : 0
            paidBeginCash   : 0
            debtIncurredCash: 0
            paidIncurredCash: 0
            debtSaleCash    : 0
            paidSaleCash    : 0
            returnSaleCash  : 0
    )

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



