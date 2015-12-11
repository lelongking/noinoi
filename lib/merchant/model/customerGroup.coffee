simpleSchema.customerGroups = new SimpleSchema
  name        : simpleSchema.StringUniqueIndex
  nameSearch  : simpleSchema.searchSource('name')

  description : simpleSchema.OptionalString
  staff       : simpleSchema.OptionalString
  priceBook   : simpleSchema.OptionalString
  totalCash   : type: Number, defaultValue: 0
  customerLists : type: [String], defaultValue: []


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
  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator('creator')
  version     : { type: simpleSchema.Version }
  isBase      :
    type: Boolean
    autoValue: ->
      if @isInsert
        return false
      else if @isUpsert
        return { $setOnInsert: false }
      return

Schema.add 'customerGroups', "CustomerGroup", class CustomerGroup
  @transform: (doc) ->
    doc.customerCount = ->
      if @customerLists
        if User.hasManagerRoles()
          @customerLists.length
        else
          _.intersection(@customerLists, Meteor.users.findOne(Meteor.userId()).profile.customers).length
      else 0

    doc.reCalculateTotalCash = ->
      totalCash = 0
      Schema.customers.find({group: @_id}).forEach((customer) -> totalCash += (customer.debtCash + customer.loanCash))
      Schema.customerGroups.update @_id, $set:{totalCash: totalCash}

    doc.remove = ->
      if @allowDelete
        Schema.customerGroups.remove(@_id)
        findCustomerGroup = Schema.customerGroups.findOne({isBase: true, merchant: Merchant.getId()})
        CustomerGroup.setSessionCustomerGroup(findCustomerGroup._id) if findCustomerGroup

    doc.changeCustomerTo = (customerGroupId) ->
      if user = Meteor.users.findOne(Meteor.userId())
        customerList = []; customerSelected = user.sessions.customerSelected[@_id]
        for customerId in customerSelected
          if customerFound = Schema.customers.findOne({_id: customerId, customerOfGroup: @_id})
            Schema.customers.update(customerFound._id, $set: {customerOfGroup: customerGroupId})
            customerList.push(customerFound._id)


        updateGroupFrom = $pullAll:{customerLists: customerSelected}
        customerNotExistedCount = (_.difference(@customerLists, customerSelected)).length
        updateGroupFrom.$set = {allowDelete: true} if customerNotExistedCount is 0 and @isBase is false
#        updateGroupFrom.$inc = {totalCash: -(customerFound.debtCash + customerFound.loanCash)}
        Schema.customerGroups.update @_id, updateGroupFrom

        updateGroupTo = $set:{allowDelete: false}, $addToSet:{customerLists: {$each: customerList}}
#        updateGroupTo.$inc = {totalCash: customerFound.debtCash + customerFound.loanCash}
        Schema.customerGroups.update customerGroupId, updateGroupTo

        userUpdate = $set:{}; userUpdate.$set["sessions.customerSelected.#{@_id}"] = []
        Meteor.users.update(user._id, userUpdate)

    doc.selectedCustomer = (customerId)->
      if userId = Meteor.userId()
        userUpdate = $addToSet:{}; userUpdate.$addToSet["sessions.customerSelected.#{@_id}"] = customerId
        Meteor.users.update(userId, userUpdate)

    doc.unSelectedCustomer = (customerId)->
      if userId = Meteor.userId()
        userUpdate = $pull:{}; userUpdate.$pull["sessions.customerSelected.#{@_id}"] = customerId
        Meteor.users.update(userId, userUpdate)

    doc.reCalculateTotalCash = ->
      totalCash = 0
      Schema.customers.find({group: @_id}).forEach(
        (customer) ->
          totalCash +=
            (customer.debtRequiredCash ? 0) - (customer.paidRequiredCash ? 0) +
              (customer.debtBeginCash ? 0) - (customer.paidBeginCash ? 0) +
              (customer.debtIncurredCash ? 0) - (customer.paidIncurredCash ? 0) +
              (customer.debtSaleCash ? 0) - (customer.paidSaleCash ? 0) - (customer.returnSaleCash ? 0)
      )
      Schema.customerGroups.update @_id, $set:{totalCash: totalCash}

  @insert: (name, description)->
    return false if !name

    newGroup = {name: name}
    newGroup.description = description if description
    newCustomerId = Schema.customerGroups.insert newGroup
    CustomerGroup.setSessionCustomerGroup(newCustomerId) if newCustomerId
    newCustomerId

  @nameIsExisted: (name, merchant = Merchant.getId()) ->
    return true if !merchant or !name
    existedQuery = {name: name, merchant: merchant}
    if Schema.customerGroups.findOne(existedQuery) then true else false

  @setSessionCustomerGroup: (customerGroupId) ->
    return false if !customerGroupId
#    Meteor.subscribe('productManagementCurrentProductData', @_id) if Meteor.isClient
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomerGroup': customerGroupId}})

  @getBasicGroup: -> Schema.customerGroups.findOne {isBase: true, merchant: Merchant.getId()}
  @addCustomer = (customerId)->
    customer = Schema.customers.findOne(customerId)
    group = Schema.customerGroups.findOne({isBase: true})
    if customer and group
      Schema.customers.update customer._id, $set: {group: group._id}
      Schema.customerGroups.update customer.group, {$pull: {customers: customer._id }, $inc:{totalCash: -customer.totalCash}} if customer.group
      Schema.customerGroups.update group._id, {$addToSet: {customers: customer._id }, $inc:{totalCash: customer.totalCash}}

  @recalculateTotalCash : ->
    Schema.customerGroups.find().forEach( (group) -> group.reCalculateTotalCash() )

  @update: ->
    Schema.customerGroups.find({}).forEach(
      (customerGroup)->
        customerListIds = []
        Schema.customers.find({$or: [ {group: customerGroup._id}, {customerOfGroup: customerGroup._id} ]} ).forEach(
          (customer) ->
            customerListIds.push(customer._id)
            Schema.customers.update customer._id, $set:{customerOfGroup: customerGroup._id}
        )
        Schema.customerGroups.update customerGroup._id, $set: {customerLists: customerListIds}
    )