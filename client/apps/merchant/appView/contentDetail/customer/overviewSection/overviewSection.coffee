scope = {}
Wings.defineHyper 'customerManagementOverviewSection',
  created: ->
    console.log 'customerOverview created'
  rendered: ->
    console.log 'customerOverview rendered'
    Session.set('customerManagementIsShowCustomerDetail', false)
    Session.set("customerManagementShowEditCommand", false)

    scope.overviewTemplateInstance = @
    @ui.$customerName.autosizeInput({space: 10}) if @ui.$customerName


  destroyed: ->
    console.log 'customerOverview destroyed'

  helpers:
    showEditCommand: -> if Session.get("customerManagementShowEditCommand") then '' else 'hidden'
    showDeleteCommand: -> if @allowDelete then '' else 'hidden'
    isShowTab: (text)-> if Session.equals("customerManagementIsShowCustomerDetail", text) then '' else 'hidden'

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$customerName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$customerName?
      @name

  events:
    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      updateChangeAvatar(event, template)

    "input input.editable": (event, template) ->
      checkAllowUpdateOverview(template)

    "keyup input.editable": (event, template) ->
      if event.which is 13 and template.data
        editCustomer(template)
      else if event.which is 27 and template.data
        rollBackCustomerData(event, template)
      checkAllowUpdateOverview(template)

    "click .syncCustomerEdit": (event, template) ->
      editCustomer(template)

    "click .customerDelete": (event, template) ->





    "keyup .editDescription": (event, template) ->
      description = $(template.find(".editDescription")).val()
      customer = Session.get("customerManagementCurrentCustomer")
      Helpers.deferredAction ->
        if customer
          Schema.customers.update(customer._id, $set:{description: description ? ""})
      , "customerManagementUpdateDescription"
      , 2000






#    "keyup [name='customerCode']": (event, template) ->
#      $customerCode   = $(template.find("[name='customerCode']"))
#      currentCustomer = template.data
#      Helpers.deferredAction ->
#        if $customerCode.val() isnt currentCustomer.code
#          Schema.customers.update(currentCustomer._id, $set:{customerCode: $customerCode.val()})
##            ProductSearch.cleanHistory()
##            ProductSearch.search Session.get("productManagementSearchFilter")
#      , "customerManagerChangeCustomerCode"
#      , 1000
#      event.stopPropagation()

#    "keyup [name='deliveryAddress']": (event, template) ->
#      $deliveryAddress  = $(template.find("[name='deliveryAddress']"))
#      currentCustomer   = template.data
#      Helpers.deferredAction ->
#        if $deliveryAddress.val() isnt currentCustomer.deliveryAddress
#          Schema.customers.update(currentCustomer._id, $set:{deliveryAddress: $deliveryAddress.val()})
##            ProductSearch.cleanHistory()
##            ProductSearch.search Session.get("productManagementSearchFilter")
#      , "customerManagerChangeCustomerDeliveryAddress"
#      , 1000
#      event.stopPropagation()


    "click span.hideTab": (event, template)->
      Session.set('customerManagementIsShowCustomerDetail', false)
    "click span.showTab": (event, template)->
      Session.set('customerManagementIsShowCustomerDetail', true)





checkAllowUpdateOverview = (template) ->
  customerData = template.data
  Session.set "customerManagementShowEditCommand",
    template.ui.$customerName.val() isnt customerData.name or
      template.ui.$customerPhone.val() isnt (customerData.phone ? '') or
      template.ui.$customerCode.val() isnt (customerData.code ? '')

rollBackCustomerData = (event, template)->
  customerData = template.data
  if $(event.currentTarget).attr('name') is 'customerName'
    $(event.currentTarget).val(customerData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'customerPhone'
    $(event.currentTarget).val(customerData.phone)
  else if $(event.currentTarget).attr('name') is 'customerCode'
    $(event.currentTarget).val(customerData.code)

updateChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; customer = Template.currentData()
    if files.length > 0 and customer?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.customers.update(customer._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(customer.avatar)?.remove()


editCustomer = (template) ->
  customer = template.data
  if customer and Session.get("customerManagementShowEditCommand")
    name  = template.ui.$customerName.val()
    phone = template.ui.$customerPhone.val()
    code  = template.ui.$customerCode.val()

    return if name.replace("(", "").replace(")", "").trim().length < 2
    editOptions = Helpers.splitName(name)
    editOptions.phone = phone if phone.length > 0
    editOptions.code  = code if code.length > 0

    console.log editOptions

    if editOptions.name.length > 0
      customerFound = Schema.customers.findOne
        name          : editOptions.name
        parentMerchant: customer.parentMerchant

    if editOptions.name.length is 0
      template.ui.$customerName.notify("Tên khách hàng không thể để trống.", {position: "right"})
    else if customerFound and customerFound._id isnt customer._id
      template.ui.$customerName.notify("Tên khách hàng đã tồn tại.", {position: "right"})
      template.ui.$customerName.val editOptions.name
      Session.set("customerManagementShowEditCommand", false)

    else if editOptions.code.length is 0
      template.ui.$customerCode.notify("Mã khách hàng không thể để trống.", {position: "right"})
    else if customerFound and customerFound._id isnt customer._id
      template.ui.$customerName.notify("Tên khách hàng đã tồn tại.", {position: "right"})
      template.ui.$customerName.val editOptions.name
      Session.set("customerManagementShowEditCommand", false)

    else
      Schema.customers.update customer._id, {$set: editOptions}, (error, result) -> if error then console.log error
      template.ui.$customerName.val editOptions.name
      Session.set("customerManagementShowEditCommand", false)