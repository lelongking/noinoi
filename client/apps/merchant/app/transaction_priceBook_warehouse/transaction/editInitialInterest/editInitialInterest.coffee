Wings.defineHyper 'editInitialInterest',
  helpers:
    currentOwner: -> Session.get('transactionOwner')
    isEditMode: (text)-> if Session.get("transactionEditInitialInterest")?.isEditMode is text then '' else 'hidden'
    isRowEditing: -> @_id is Session.get('transactionOwner')?._id

    details: ->
      transaction = Session.get('transactionDetail'); count = 0
      if transaction.isOwner is 'customer'
        Schema.customers.find({}).map(
          (item) ->
            count += 1
            item.count = count
            item
        )
      else if transaction.isOwner is 'provider'
        Schema.providers.find({}).map(
          (item) ->
            count += 1
            item.count = count
            item
        )

  events:
    "click .editOwner": (event, template) ->
      Session.set('transactionOwner', @)

Wings.defineHyper 'editInitialInterestRowEditing',
  rendered: ->
    owner = Session.get('transactionOwner')
    editInitialInterest =
      ownerId             : owner._id
      initialAmount       : owner.initialAmount ? 0
      initialInterestRate : owner.initialInterestRate ? 0
      initialStartDate    : owner.initialStartDate ? new Date()
      isEditMode          : false
    Session.set('transactionEditInitialInterest',  editInitialInterest)


    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits: 12}
    $initialAmount = self.ui.$initialAmount
    $initialAmount.inputmask "integer", integerOption
    $initialAmount.val editInitialInterest.initialAmount

    decimalOption        = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: "%/tháng", integerDigits:4}
    $initialInterestRate = self.ui.$initialInterestRate
    $initialInterestRate.inputmask "decimal", decimalOption
    $initialInterestRate.val editInitialInterest.initialInterestRate


    self.autorun ()->
      owner    = Session.get('transactionOwner')
      editData = Session.get('transactionEditInitialInterest')
      if owner and editData
        if owner._id isnt editData.ownerId
          editData =
            ownerId             : owner._id
            initialAmount       : owner.initialAmount ? 0
            initialInterestRate : owner.initialInterestRate ? 0
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
          transactionOwner  = Session.get('transactionOwner')
          transactionEdit   = Session.get('transactionEditInitialInterest')
          transactionDetail = Session.get('transactionDetail')
          if transactionDetail and transactionOwner and transactionEdit
            ownerUpdate = $set: {
              initialAmount       : transactionEdit.initialAmount
              initialInterestRate : transactionEdit.initialInterestRate
              initialStartDate    : transactionEdit.initialStartDate
            }
            Schema.providers.update transactionOwner._id, ownerUpdate if transactionOwner.model is 'providers'
            Schema.customers.update transactionOwner._id, ownerUpdate if transactionOwner.model is 'customers'

            transactionEdit.isEditMode = false
            Session.set('transactionEditInitialInterest',  transactionEdit)

            transactionDetail.owner = ''
            Session.set('transactionDetail',  transactionDetail)
            Session.set('transactionOwner')



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

    "click .syncEditInitialInterest": (event, template) ->
      transactionOwner  = Session.get('transactionOwner')
      transactionEdit   = Session.get('transactionEditInitialInterest')
      transactionDetail = Session.get('transactionDetail')
      if transactionDetail and transactionOwner and transactionEdit
        ownerUpdate = $set: {
          initialAmount       : transactionEdit.initialAmount
          initialInterestRate : transactionEdit.initialInterestRate
          initialStartDate    : transactionEdit.initialStartDate
        }
        Schema.providers.update transactionOwner._id, ownerUpdate if transactionOwner.model is 'providers'
        Schema.customers.update transactionOwner._id, ownerUpdate if transactionOwner.model is 'customers'

        transactionEdit.isEditMode = false
        Session.set('transactionEditInitialInterest',  transactionEdit)

        transactionDetail.owner = ''
        Session.set('transactionDetail',  transactionDetail)
        Session.set('transactionOwner')

