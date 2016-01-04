Wings.defineHyper 'customerCreate',
  created: ->
    Session.set("customerCreateSelectedGroup", 'skyReset')

  rendered: ->
    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", rightAlign: false, suffix: " VNĐ", integerDigits: 11}
    $customerInitialDebit = self.ui.$customerInitialDebit
    $customerInitialDebit.inputmask "integer", integerOption

    decimalOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", rightAlign: false, suffix: " %/tháng", integerDigits:4}
    $customerInitialInterestRate = self.ui.$customerInitialInterestRate
    $customerInitialInterestRate.inputmask "decimal", decimalOption


    self.ui.$genderSwitch.bootstrapSwitch('onText', 'Nam')
    self.ui.$genderSwitch.bootstrapSwitch('offText', 'Nữ')


  destroyed: ->
    Session.set("customerCreateSelectedGroup")


  helpers:
    codeDefault: ->
      merchantSummaries = Session.get('merchant')?.summaries ? {}
      lastCode          = merchantSummaries.lastCustomerCode ? 0
      listCustomerCodes = merchantSummaries.listCustomerCodes ? []
      Wings.Helper.checkAndGenerateCode(lastCode, listCustomerCodes)

    customerGroupSelect: -> customerCreateSelectGroup

  events:
    "click .cancelCustomer": (event, template) ->
      FlowRouter.go('customer')

    "click .addCustomer": (event, template) ->
      addNewCustomer(event, template)

    "blur [name='customerName']": (event, template) ->
      checkCustomerName(event, template)

    "blur [name='customerPhone']": (event, template) ->
      checkCustomerPhone(event, template)

    "blur [name='customerCode']": (event, template) ->
      checkCustomerCode(event, template)


customerCreateSelectGroup =
  query: (query) -> query.callback
    results: Schema.customerGroups.find(
      {$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not: 'asda' }}]}
    ,
      {sort: {nameSearch: 1, name: 1}}
    ).fetch()
    text: 'name'
  initSelection: (element, callback) -> callback Session.get("customerCreateSelectedGroup") ? 'skyReset'
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'Chọn nhóm'
  changeAction: (e) -> Session.set("customerCreateSelectedGroup", e.added)
  reactiveValueGetter: -> Session.get("customerCreateSelectedGroup") ? 'skyReset'



checkCustomerName = (event, template, customer) ->
  $customerName = template.ui.$customerName
  customerName = $customerName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if customerName.length > 0
    $customerName.removeClass('error')
    customer.name = customerName if customer
  else
    $customerName.addClass('error')
    $customerName.notify('tên không được để trống', {position: "right"})
    return false

checkCustomerPhone = (event, template, customer) ->
  $customerPhone     = template.ui.$customerPhone
  customerPhone      = $customerPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
  listCustomerPhones = Session.get('merchant')?.summaries?.listCustomerPhones ? []
  if customerPhone.length > 0
    if _.indexOf(listCustomerPhones, $customerPhone.val()) > -1
      $customerPhone.addClass('error')
      $customerPhone.notify('số điện thoại đã bị sử dụng', {position: "right"})
      return false
    else
      customer.phone = customerPhone if customer
      $customerPhone.removeClass('error')
  else
    $customerPhone.removeClass('error')
    $customerPhone.val('')

checkCustomerCode = (event, template, customer) ->
  $customerCode     = template.ui.$customerCode
  customerCode      = $customerCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  listCustomerCodes = Session.get('merchant')?.summaries?.listCustomerCodes ? []

  if customerCode.length > 0
    if _.indexOf(listCustomerCodes, customerCode) > -1
      $customerCode.addClass('error')
      $customerCode.notify('mã khách hàng đã bị sử dụng', {position: "right"})
      return
    else
      customer.code = customerCode if customer
      $customerCode.removeClass('error')
  else
    $customerCode.removeClass('error')
    $customerCode.val('')

addNewCustomer = (event, template, customer = {}) ->
  if checkCustomerName(event, template, customer)
    if checkCustomerPhone(event, template, customer)
      if checkCustomerCode(event, template, customer)
        $customerAddress = template.ui.$customerAddress
        customerAddress  = $customerAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
        customer.address = customerAddress if customerAddress

        customerGender = template.ui.$genderSwitch.bootstrapSwitch('state')
        customer.profiles = {gender: customerGender}

        customerBirth  = template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates.get()
        customer.profiles.dateOfBirth = customerBirth if customerBirth

        $customerDescription = template.ui.$customerDescription
        customerDescription  = $customerDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
        customer.profiles.description = customerDescription if customerDescription.length > 0

        selectGroupId = Session.get("customerCreateSelectedGroup")?._id
        customer.customerOfGroup = selectGroupId if selectGroupId

        initialInterestRate = parseInt(template.ui.$customerInitialInterestRate.inputmask('unmaskedvalue'))
        customer.initialInterestRate = initialInterestRate if initialInterestRate isnt NaN

        initialStartDate  = template.datePicker.$dateDebit.datepicker().data().datepicker.dates.get()
        customer.initialStartDate = initialStartDate if initialStartDate

        initialAmount = parseInt(template.ui.$customerInitialDebit.inputmask('unmaskedvalue'))
        if initialAmount isnt NaN
          customer.initialAmount       = initialAmount
          customer.initialInterestRate = 0 if !customer.initialInterestRate
          customer.initialStartDate    = new Date() if !customer.initialStartDate



        newCustomerId = Schema.customers.insert customer
        if Match.test(newCustomerId, String)
          Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': newCustomerId}})
          FlowRouter.go('customer')
          toastr["success"]("Tạo khách hàng thành công.")

