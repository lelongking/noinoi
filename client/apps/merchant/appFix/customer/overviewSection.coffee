@CustomerCreate = ()->
  Customer.insert(item.name, item.description) for item in a

scope = logics.customerManagement

Wings.defineHyper 'customerManagementOverviewSection',
  rendered: ->
    Session.set('customerManagementIsShowCustomerDetail', false)
    scope.overviewTemplateInstance = @
    @ui.$customerName.autosizeInput({space: 10}) if @ui.$customerName

  helpers:
    showEditCommand: -> Session.get "customerManagementShowEditCommand"
    showDeleteCommand: -> Session.get("customerManagementCurrentCustomer")?.allowDelete
    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$customerName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$customerName?
      @name
    firstName: -> Helpers.firstName(@name)

    currentCustomer: -> console.log @

  events:
    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      if User.hasManagerRoles()
        files = event.target.files; customer = Template.currentData()
        if files.length > 0 and customer?._id
          AvatarImages.insert files[0], (error, fileObj) ->
            Schema.customers.update(customer._id, {$set: {avatar: fileObj._id}})
            AvatarImages.findOne(customer.avatar)?.remove()

    "input .editable": (event, template) -> scope.checkAllowUpdateOverview(template)
    "keyup .editDescription": (event, template) ->
      description = $(template.find(".editDescription")).val()
      customer = Session.get("customerManagementCurrentCustomer")
      Helpers.deferredAction ->
        if customer
          Schema.customers.update(customer._id, $set:{description: description ? ""})
      , "customerManagementUpdateDescription"
      , 2000



    "keyup input.editable": (event, template) ->
      console.log template
      if template.data
        scope.editCustomer(template) if event.which is 13

        if event.which is 27
          if $(event.currentTarget).attr('name') is 'customerName'
            $(event.currentTarget).val(template.data.name)
            $(event.currentTarget).change()
          else if $(event.currentTarget).attr('name') is 'customerPhone'
            $(event.currentTarget).val(template.data.phone)
          else if $(event.currentTarget).attr('name') is 'customerAddress'
            $(event.currentTarget).val(template.data.address)

          scope.checkAllowUpdateOverview(template)


    "keyup [name='customerCode']": (event, template) ->
      $customerCode   = $(template.find("[name='customerCode']"))
      currentCustomer = template.data
      Helpers.deferredAction ->
        if $customerCode.val() isnt currentCustomer.code
          Schema.customers.update(currentCustomer._id, $set:{customerCode: $customerCode.val()})
#            ProductSearch.cleanHistory()
#            ProductSearch.search Session.get("productManagementSearchFilter")
      , "customerManagerChangeCustomerCode"
      , 1000
      event.stopPropagation()

    "keyup [name='deliveryAddress']": (event, template) ->
      $deliveryAddress  = $(template.find("[name='deliveryAddress']"))
      currentCustomer   = template.data
      Helpers.deferredAction ->
        if $deliveryAddress.val() isnt currentCustomer.deliveryAddress
          Schema.customers.update(currentCustomer._id, $set:{deliveryAddress: $deliveryAddress.val()})
#            ProductSearch.cleanHistory()
#            ProductSearch.search Session.get("productManagementSearchFilter")
      , "customerManagerChangeCustomerDeliveryAddress"
      , 1000
      event.stopPropagation()

    "click .syncCustomerEdit": (event, template) -> scope.editCustomer(template)
    "click .customerDelete": (event, template) -> scope.currentCustomer.remove()
    "click .customerDetail span": (event, template)->
      Session.set('customerManagementIsShowCustomerDetail', !Session.get('customerManagementIsShowCustomerDetail'))