Wings.defineHyper 'productCreate',
  created: ->
    console.log 'created customerCreate'
    self = this
    self.newCustomerData = new ReactiveVar({})

  rendered: ->
    console.log 'render --------------- customerCreate'
    @ui.$genderSwitch.bootstrapSwitch('onText', 'Nam')
    @ui.$genderSwitch.bootstrapSwitch('offText', 'Nữ')

  helpers:
    codeDefault: ->
      merchantSummaries = Session.get('merchant')?.summaries ? {}
      lastCode          = merchantSummaries.lastCustomerCode ? 0
      listCustomerCodes = merchantSummaries.listCustomerCodes ? []
      Wings.Helper.checkAndGenerateCode(lastCode, listCustomerCodes)

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

        newCustomerId = Schema.customers.insert customer
        if Match.test(newCustomerId, String)
          Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': newCustomerId}})
          FlowRouter.go('customer')
          toastr["success"]("Tạo khách hàng thành công.")

