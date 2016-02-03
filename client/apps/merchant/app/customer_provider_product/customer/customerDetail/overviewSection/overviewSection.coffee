scope = {}
Enums = Apps.Merchant.Enums
Wings.defineHyper 'customerManagementOverviewSection',
  created: ->
    self = this
    self.autorun ()->

  rendered: ->
    Session.set('customerManagementIsShowCustomerDetail', false)
    Session.set("customerManagementShowEditCommand", false)
    Session.set('customerManagementIsEditMode', false)

    scope.overviewTemplateInstance = @
    @ui.$customerName.autosizeInput({space: 10}) if @ui.$customerName
    @ui.$genderSwitch.bootstrapSwitch('onText', 'Nam')
    @ui.$genderSwitch.bootstrapSwitch('offText', 'Nữ')

    if Session.get("customerManagementShowEditCommand")
      $(".changeCustomerGroup").select2("readonly", false)
    else
      $(".changeCustomerGroup").select2("readonly", true)

    @ui.$customerName.select()

  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Session.equals("customerManagementIsShowCustomerDetail", text) then '' else 'hidden'

    isEditMode: (text)->
      if Session.equals("customerManagementIsEditMode", text) then '' else 'hidden'

    showSyncCustomer: ->
      editCommand = Session.get("customerManagementShowEditCommand")
      editMode = Session.get("customerManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteCustomer: ->
      editMode = Session.get("customerManagementIsEditMode")
      isDelete =
        if @saleAmount > 0 or @returnAmount > 0 or @loanAmount > 0 or @returnPaidAmount > 0 or @paidAmount > 0 or @interestAmount > 0 or @initialAmount > 0
          false
        else
          orderCursor  = Schema.orders.find(
            buyer       : @_id
            orderStatus : { $ne: Enums.getValue('OrderStatus', 'initialize') }
          )
          returnCursor = Schema.returns.find(
            owner       : @_id
            returnType  : Enums.getValue('ReturnTypes', 'customer')
            returnStatus: Enums.getValue('ReturnStatus', 'success')
          )
          if orderCursor.count() > 0 or returnCursor.count() > 0 then false else true

      if editMode and isDelete then '' else 'hidden'

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$customerName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$customerName?
      @name

    customerGroupSelected: -> customerGroupSelects

  events:
    "click .customerDelete": (event, template) -> @remove()

    "click .editCustomer": (event, template) ->
      console.log template.data
      clickShowCustomerDetailTab(event, template)
      Session.set('customerManagementIsEditMode', true)
      template.ui.$genderSwitch.bootstrapSwitch('disabled', !Session.get('customerManagementIsEditMode'))
      $(".changeCustomerGroup").select2("readonly", false)
      checkAllowUpdateOverview(template)

    "click .syncCustomerEdit": (event, template) ->
      editCustomer(template)

    "click .cancelCustomer": (event, template) ->
      Session.set('customerManagementIsEditMode', false)
      template.ui.$genderSwitch.bootstrapSwitch('disabled', !Session.get('customerManagementIsEditMode'))
      dateOfBirth = moment(template.data.profiles.dateOfBirth).format("DD/MM/YYYY")
      template.datePicker.$dateOfBirth.datepicker('setDate', dateOfBirth)
      $(".changeCustomerGroup").select2("readonly", true)



    "click span.hideTab": (event, template)->
      Session.set('customerManagementIsShowCustomerDetail', false)

    "click span.showTab": (event, template)->
      clickShowCustomerDetailTab(event, template)



    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      updateChangeAvatar(event, template)

    "change [name='dateOfBirth']": (event, template) ->
      checkAllowUpdateOverview(template)

    'input input.customerEdit, switchChange.bootstrapSwitch input[name="genderSwitch"]': (event, template) ->
      checkAllowUpdateOverview(template)

    "keyup input.customerEdit": (event, template) ->
      if event.which is 13 and template.data
        editCustomer(template)
      else if event.which is 27 and template.data
        rollBackCustomerData(event, template)
      checkAllowUpdateOverview(template)


















customerGroupSelects =
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
  changeAction: (e) ->
    Session.set("customerCreateSelectedGroup", e.added)
    Session.set("customerManagementShowEditCommand", true)
    checkAllowUpdateOverview(template)
  reactiveValueGetter: -> Session.get("customerCreateSelectedGroup") ? 'skyReset'


#----------------------------------------------------------------------------------------------------------------------
clickShowCustomerDetailTab = (event, template)->
  customer = template.data
  if template.ui.$genderSwitch
    template.ui.$genderSwitch.bootstrapSwitch('disabled', false)
    template.ui.$genderSwitch.bootstrapSwitch('state', customer.profiles.gender)
    template.ui.$genderSwitch.bootstrapSwitch('disabled', !Session.get('customerManagementIsEditMode'))

  if template.datePicker
    dateOfBirth = if customer.profiles.dateOfBirth then moment(customer.profiles.dateOfBirth).format("DD/MM/YYYY") else ''
    template.datePicker.$dateOfBirth.datepicker('setDate', dateOfBirth)
  Session.set('customerManagementIsShowCustomerDetail', true)

  if customer.customerOfGroup
    Session.set("customerCreateSelectedGroup", Schema.customerGroups.findOne({_id: customer.customerOfGroup}))

checkAllowUpdateOverview = (template) ->
  customerData        = template.data
  customerName        = template.ui.$customerName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  customerPhone       = template.ui.$customerPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
  customerCode        = template.ui.$customerCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  customerAddress     = template.ui.$customerAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
  customerDescription = template.ui.$customerDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
  customerGender      = template.ui.$genderSwitch.bootstrapSwitch('state')
  customerDateOfBirth = template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates.get()
  customerDateOfBirth = moment(customerDateOfBirth).format("DD/MM/YYYY") if customerDateOfBirth
  customerOfGroup     = Session.get("customerCreateSelectedGroup")?._id

  Session.set "customerManagementShowEditCommand",
    customerName isnt customerData.name or
      customerCode isnt (customerData.code ? '') or
      customerPhone isnt (customerData.phone ? '') or
      customerGender isnt (customerData.profiles.gender ? '') or
      customerAddress isnt (customerData.address ? '') or
      customerOfGroup isnt (customerData.customerOfGroup ? '') or
      customerDateOfBirth isnt (
        if customerData.profiles.dateOfBirth
          moment(customerData.profiles.dateOfBirth).format("DD/MM/YYYY")
        else
         undefined
      ) or
      customerDescription isnt (customerData.profiles.description ? '')


rollBackCustomerData = (event, template)->
  customerData = template.data
  if $(event.currentTarget).attr('name') is 'customerName'
    $(event.currentTarget).val(customerData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'customerCode'
    $(event.currentTarget).val(customerData.code)
  else if $(event.currentTarget).attr('name') is 'customerPhone'
    $(event.currentTarget).val(customerData.phone)
  else if $(event.currentTarget).attr('name') is 'genderSwitch'
    $(event.currentTarget).bootstrapSwitch('state', template.data.profiles.gender)
  else if $(event.currentTarget).attr('name') is 'customerAddress'
    $(event.currentTarget).val(customerData.address)
  else if $(event.currentTarget).attr('name') is 'dateOfBirth'
    $(event.currentTarget).datepicker('setDate', customerData.profiles.dateOfBirth)
  else if $(event.currentTarget).attr('name') is 'customerDescription'
    $(event.currentTarget).val(customerData.profiles.description)

updateChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; customer = Template.currentData()
    if files.length > 0 and customer?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.customers.update(customer._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(customer.avatar)?.remove()

editCustomer = (template) ->
  customer   = template.data
  summaries = Session.get('merchant')?.summaries
  if customer and Session.get("customerManagementShowEditCommand")
    name            = template.ui.$customerName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    phone           = template.ui.$customerPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
    code            = template.ui.$customerCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
    address         = template.ui.$customerAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description     = template.ui.$customerDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
    gender          = template.ui.$genderSwitch.bootstrapSwitch('state')
    dateOfBirth     = template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates.get()?.toString()
    customerOfGroup = Session.get("customerCreateSelectedGroup")?._id

    listPhones  = summaries.listCustomerPhones ? []
    listCodes   = summaries.listCustomerCodes ? []

    editOptions = {}
    editOptions.name            = name if name isnt customer.name
    editOptions.phone           = phone if phone isnt customer.phone
    editOptions.code            = code if code isnt customer.code
    editOptions.address         = address if address isnt customer.address
    editOptions.customerOfGroup = customerOfGroup if customerOfGroup isnt customer.customerOfGroup
    editOptions['profiles.description'] = description if description isnt customer.profiles.description
    editOptions['profiles.gender'     ] = gender if gender isnt customer.profiles.gender
    editOptions['profiles.dateOfBirth'] = dateOfBirth if dateOfBirth isnt customer.profiles.dateOfBirth


    console.log listCodes, editOptions.code, _.indexOf(listCodes, editOptions.code)
    if editOptions.name isnt undefined  and editOptions.name.length is 0
      template.ui.$customerName.notify("Tên khách hàng không thể để trống.", {position: "right"})

    else if editOptions.code isnt undefined
      if editOptions.code.length > 0
        if listCodes.length > 0 and _.indexOf(listCodes, editOptions.code) isnt -1
          return template.ui.$customerCode.notify("Mã khách hàng đã tồn tại.123123123", {position: "right"})
      else
        return template.ui.$customerCode.notify("Mã khách hàng không thể để trống.", {position: "right"})

    else if editOptions.phone isnt undefined and listPhones.length > 0 and _.indexOf(listPhones, editOptions.phone) isnt -1
      return template.ui.$customerPhone.notify("Số điện thoại đã tồn tại.", {position: "right"})


    if _.keys(editOptions).length > 0
      Schema.customers.update customer._id, {$set: editOptions}, (error, result) ->
        if error then console.log error
        else

          if customer.customerOfGroup isnt customerOfGroup
            groupFrom = Schema.customerGroups.findOne({_id: customer.customerOfGroup})
            groupTo   = Schema.customerGroups.findOne({_id: customerOfGroup})

            updateGroupFrom = $pullAll:{customerLists: [customer._id]}
            updateGroupFrom.$set = {allowDelete: true}
            Schema.customerGroups.update groupFrom._id, updateGroupFrom

            updateGroupTo = $set:{allowDelete: false}, $addToSet:{customerLists: customer._id}
            Schema.customerGroups.update groupTo._id, updateGroupTo




      Session.set("customerManagementShowEditCommand", false)
      Session.set('customerManagementIsEditMode', false)
      template.ui.$genderSwitch.bootstrapSwitch('disabled', true)
      $(".changeCustomerGroup").select2("readonly", true)
      toastr["success"]("Cập nhật khách hàng thành công.")


