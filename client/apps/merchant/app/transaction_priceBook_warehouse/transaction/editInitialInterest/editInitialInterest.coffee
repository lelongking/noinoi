Wings.defineHyper 'editInitialInterest',
  helpers:
    currentOwner: -> Session.get('transactionOwner')
    isEditMode: (text)-> if Session.get("transactionEditInitialInterest")?.isEditMode is text then '' else 'hidden'
    isRowEditing: -> @_id is Session.get('transactionOwner')?._id

    ownerName: ->
      transaction = Session.get('transactionDetail')
      if transaction?.isOwner is 'provider'
        'nhà cung cấp'
      else if transaction?.isOwner is 'customer'
        'khách hàng'

    hideIsProvider: ->
      transaction = Session.get('transactionDetail')
      if transaction?.isOwner is 'provider'
        'hidden'
      else if transaction?.isOwner is 'customer'
        ''

    interestRateInitial: ->
      if @initialInterestRate is undefined
        Session.get('merchant')?.interestRates?.initial ? 0
      else
        @initialInterestRate

    details: ->
      merchantId = Merchant.getId()
      transaction = Session.get('transactionDetail'); count = 0
      detailLists = []
      if transaction.isOwner is 'customer'
        detailLists = Schema.customers.find({merchant: merchantId}, {sort: {nameSearch: 1}}).map(
          (item) ->
            count += 1
            item.count = count
            item
        )
      else if transaction.isOwner is 'provider'
        detailLists = Schema.providers.find({merchant: merchantId}, {sort: {nameSearch: 1}}).map(
          (item) ->
            count += 1
            item.count = count
            item
        )

      ownerSearchText = Session.get('editInitialInterestOwnerSearchText')
      if ownerSearchText?.length > 0 and  detailLists.length > 0
        detailLists = _.filter detailLists, (owner) ->
          unsignedTerm = Helpers.RemoveVnSigns ownerSearchText
          unsignedName = Helpers.RemoveVnSigns owner.name
          unsignedName.indexOf(unsignedTerm) > -1

      detailLists

  events:
    "click .editOwner": (event, template) ->
      Session.set('transactionOwner', @)

    "click .searchOwner": (event, template) ->
      isSearch = Session.get("editInitialInterestSearchOwner")
      Session.set("editInitialInterestSearchOwner", !isSearch)
      Session.set("editInitialInterestOwnerSearchText",'')

    "keyup input[name='searchOwnerFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter = $("input[name='searchOwnerFilter']").val()
        searchFilter = searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," ")
        Session.set("editInitialInterestOwnerSearchText", searchFilter)
        Session.set("editInitialInterestSearchOwner", false) if searchFilter.length is 0
      , "editInitialInterestSearchText"
      , 200


Wings.defineHyper 'editInitialInterestRowEditing',
  rendered: ->
    interestRates = Session.get('merchant')?.interestRates
    owner = Session.get('transactionOwner')
    editInitialInterest =
      ownerId             : owner._id
      initialAmount       : owner.initialAmount ? 0
      initialInterestRate : owner.initialInterestRate ? (interestRates.initial ? 0)
      initialStartDate    : owner.initialStartDate ? new Date()
      isEditMode          : false
    Session.set('transactionEditInitialInterest',  editInitialInterest)


    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: "", integerDigits: 12}
    $initialAmount = self.ui.$initialAmount
    $initialAmount.inputmask "integer", integerOption
    $initialAmount.val editInitialInterest.initialAmount

    decimalOption        = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: "", integerDigits:3}
    $initialInterestRate = self.ui.$initialInterestRate
    $initialInterestRate.inputmask "decimal", decimalOption
    $initialInterestRate.val editInitialInterest.initialInterestRate

    $initialAmount.select()


    self.autorun ()->
      owner    = Session.get('transactionOwner')
      editData = Session.get('transactionEditInitialInterest')
      if owner and editData
        if owner._id isnt editData.ownerId
          editData =
            ownerId             : owner._id
            initialAmount       : owner.initialAmount ? 0
            initialInterestRate : owner.initialInterestRate ? (interestRates.initial ? 0)
            initialStartDate    : owner.initialStartDate ? new Date()
            isEditMode          : false
          Session.set('transactionEditInitialInterest',  editData)


        initialAmountValue = parseInt($initialAmount.inputmask('unmaskedvalue'))
        if initialAmountValue isnt (editData.initialAmount ? 0)
          $initialAmount.val (editData.initialAmount ? 0)

        initialInterestRateValue = parseInt($initialInterestRate.inputmask('unmaskedvalue'))
        if initialInterestRateValue isnt (editData.initialInterestRate ? 0)
          $initialInterestRate.val (editData.initialInterestRate ? 0)

        if editData.initialStartDate
          initialStartDate = moment(editData.initialStartDate).format("DD/MM/YYYY")
          self.datePicker.$dateDebit.datepicker('setDate', initialStartDate)
        else
          self.datePicker.$dateDebit.datepicker('setDate', new Date())
#          self.datePicker.$dateDebit.datepicker('clearDates')

  helpers:
    isEditMode: (text)->
      if Session.get("transactionEditInitialInterest")?.isEditMode is text then '' else 'hidden'

    hideIsProvider: ->
      transaction = Session.get('transactionDetail')
      if transaction?.isOwner is 'provider'
        'hidden'
      else if transaction?.isOwner is 'customer'
        ''


  events:
    "keyup .input-field":  (event, template) ->
      owner = Session.get('transactionOwner')
      edit  = Session.get('transactionEditInitialInterest')
      if owner and edit
        if event.target.name is 'initialAmount'
          initialAmount = parseInt(template.ui.$initialAmount.inputmask('unmaskedvalue'))
          edit.initialAmount = initialAmount
          edit.isEditMode    = true
          Session.set('transactionEditInitialInterest',  edit)

        else if event.target.name is 'initialInterestRate'
          initialInterestRate = parseInt(template.ui.$initialInterestRate.inputmask('unmaskedvalue'))
          edit.initialInterestRate = initialInterestRate
          edit.isEditMode          = true
          Session.set('transactionEditInitialInterest',  edit)

        if event.which is 13
          updateInitialInterest()



    "change [name='dateDebit']": (event, template) ->
      owner = Session.get('transactionOwner')
      edit  = Session.get('transactionEditInitialInterest')
      date  = template.datePicker.$dateDebit.datepicker().data().datepicker.dates[0]
      if owner and edit and date?.toDateString() isnt (owner.initialStartDate?.toDateString() ? undefined)
        edit.initialStartDate = date
        edit.isEditMode       = true
        Session.set('transactionEditInitialInterest',  edit)

    "click .rollbackEditInitialInterest": (event, template) ->
      transactionOwner  = Session.get('transactionOwner')
      transactionEdit   = Session.get('transactionEditInitialInterest')
      transactionDetail = Session.get('transactionDetail')

      if transactionOwner
        template.ui.$initialAmount.val(transactionOwner.initialAmount ? 0)
        template.ui.$initialInterestRate.val(transactionOwner.initialInterestRate ? 0)
        if transactionOwner.initialStartDate
          initialStartDate = moment(transactionOwner.initialStartDate).format("DD/MM/YYYY")
        else
          initialStartDate = new Date()
        template.datePicker.$dateDebit.datepicker('setDate', initialStartDate)

        editInitialInterest =
          initialAmount       : transactionOwner.initialAmount
          initialInterestRate : transactionOwner.initialInterestRate
          initialStartDate    : transactionOwner.initialStartDate ? new Date()
          isEditMode          : false
        Session.set('transactionEditInitialInterest',  editInitialInterest)

        transactionDetail.owner = ''
        Session.set('transactionDetail',  transactionDetail)
        Session.set('transactionOwner')

    "click .syncEditInitialInterest": (event, template) -> updateInitialInterest()



updateInitialInterest = ->
  transactionOwner  = Session.get('transactionOwner')
  transactionEdit   = Session.get('transactionEditInitialInterest')
  transactionDetail = Session.get('transactionDetail')
  if transactionDetail and transactionOwner and transactionEdit
    ownerUpdate = $set: {
      initialAmount       : transactionEdit.initialAmount
      initialInterestRate : transactionEdit.initialInterestRate
      initialStartDate    : transactionEdit.initialStartDate
    }
    if transactionOwner.model is 'providers'
      Schema.providers.update transactionOwner._id, ownerUpdate
    else if transactionOwner.model is 'customers'
      Schema.customers.update transactionOwner._id, ownerUpdate
      Meteor.call 'reCalculateCustomerInterestAmount', transactionOwner._id

      merchant = Merchant.get()
      if merchant.interestRates is undefined or merchant.interestRates.initial is undefined
        if ownerUpdate.initialInterestRate isnt undefined
          Schema.merchants.update merchant._id, $set:{'interestRates.initial': ownerUpdate.initialInterestRate}
          Meteor.call 'checkInterestCash', true


    transactionEdit.isEditMode = false
    Session.set('transactionEditInitialInterest',  transactionEdit)

    transactionDetail.owner = ''
    Session.set('transactionDetail',  transactionDetail)
    Session.set('transactionOwner')