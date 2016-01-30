Enums = Apps.Merchant.Enums
Wings.defineHyper 'interestRateCustomerOverviewSection',
  created: ->
    self = this
    self.autorun ()->
    Session.set('customerManagementIsShowCustomerDetail', false)
    Session.set('customerManagementIsEditMode', false)
    Session.set("customerManagementShowEditCommand", false)

  rendered: ->
    self = this
    decimalOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: "", integerDigits:3,  rightAlign: true }
    $initialInterest = self.ui.$initialInterest
    $initialInterest.inputmask "decimal", decimalOption
#    $initialInterest.val

    $saleInterest = self.ui.$saleInterest
    $saleInterest.inputmask "decimal", decimalOption
#    $saleInterest.val editInitialInterest.saleInterest

#    Session.set('customerManagementIsShowCustomerDetail', false)

    Session.set('customerManagementIsShowCustomerDetail', false)
    Session.set('customerManagementIsEditMode', false)
    Session.set("customerManagementShowEditCommand", false)

    $initialInterest.select()

  destroyed: ->


  helpers:
    interestRateInitial: ->
      interestRates = Session.get('merchant')?.interestRates
      if @initialInterestRate is undefined
        interestRates.initial + ' %/tháng (mặc định)'
      else
        @initialInterestRate + ' %/tháng'


    interestRateSale: ->
      interestRates = Session.get('merchant')?.interestRates
      if @saleInterestRate is undefined
        interestRates.sale + ' %/tháng (mặc định)'
      else
        @saleInterestRate + ' %/tháng'


    isEditMode: (text)->
      if Session.equals("customerManagementIsEditMode", text) then '' else 'hidden'

    showSyncCustomer: ->
      editCommand = Session.get("customerManagementShowEditCommand")
      editMode = Session.get("customerManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteCustomer: ->
      editMode = Session.get("customerManagementIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'

  events:
    "click .editCustomer": (event, template) ->
      Session.set('customerManagementIsEditMode', true)

      interestRates = Session.get('merchant')?.interestRates
      customer      = Template.instance().data

      template.ui.$initialInterest.val if customer.initialInterestRate is undefined then (interestRates.initial ? 0) else customer.initialInterestRate
      template.ui.$saleInterest.val if customer.saleInterestRate is undefined then (interestRates.sale ? 0) else customer.saleInterestRate

      checkAllowUpdateOverview(template)

    "click .syncCustomerEdit": (event, template) ->
      editCustomer(template)

    "click .cancelCustomer": (event, template) ->
      Session.set('customerManagementIsEditMode', false)

    'input input.customerEdit, switchChange.bootstrapSwitch input[name="genderSwitch"]': (event, template) ->
      checkAllowUpdateOverview(template)

    "keyup input.customerEdit": (event, template) ->
      if event.which is 13 and template.data
        editCustomer(template)
      else if event.which is 27 and template.data
        rollBackCustomerData(event, template)
      checkAllowUpdateOverview(template)



checkAllowUpdateOverview = (template) ->
  customerData    = template.data
  initialInterest = template.ui.$initialInterest.inputmask('unmaskedvalue')
  saleInterest    = template.ui.$saleInterest.inputmask('unmaskedvalue')

  Session.set "customerManagementShowEditCommand",
    saleInterest isnt (customerData.saleInterestRate.toString() ? '')
      initialInterest isnt (customerData.initialInterestRate.toString() ? '')



rollBackCustomerData = (event, template)->
  customerData = template.data
  if $(event.currentTarget).attr('name') is 'initialInterest'
    $(event.currentTarget).val(customerData.initialInterestRate)
  else if $(event.currentTarget).attr('name') is 'saleInterest'
    $(event.currentTarget).val(customerData.saleInterestRate)




editCustomer = (template) ->
  customer   = template.data
  if customer and Session.get("customerManagementShowEditCommand")
    initialInterest = template.ui.$initialInterest.inputmask('unmaskedvalue')
    saleInterest    = template.ui.$saleInterest.inputmask('unmaskedvalue')


    editOptions = {}
    editOptions.initialInterestRate = initialInterest if initialInterest isnt customer.initialInterestRate
    editOptions.saleInterestRate    = saleInterest if saleInterest isnt customer.saleInterestRate


    if _.keys(editOptions).length > 0
      Schema.customers.update customer._id, {$set: editOptions}, (error, result) ->
        if error then console.log error
        else
          Meteor.call 'reCalculateCustomerInterestAmount', customer._id




      Session.set("customerManagementShowEditCommand", false)
      Session.set('customerManagementIsEditMode', false)
      toastr["success"]("Cập nhật khách hàng thành công.")


