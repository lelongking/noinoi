Wings.defineHyper 'editInitialInterest',
  created: ->

  rendered: ->
    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits: 11}
    $initialAmount = self.ui.$initialAmount
    $initialAmount.inputmask "integer", integerOption
    $initialAmount.val 0

    decimalOption        = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:4}
    $initialInterestRate = self.ui.$initialInterestRate
    $initialInterestRate.inputmask "decimal", decimalOption
    $initialInterestRate.val 0


    self.autorun ()->
      if owner = Session.get('transactionOwner')
        initialAmountValue = parseInt($initialAmount.inputmask('unmaskedvalue'))
        if initialAmountValue isnt (owner.initialAmount ? 0)
          $initialAmount.val (owner.initialAmount ? 0)

        initialInterestRateValue = parseInt($initialInterestRate.inputmask('unmaskedvalue'))
        if initialInterestRateValue isnt (owner.initialInterestRate ? 0)
          $initialInterestRate.val (owner.initialInterestRate ? 0)

        if owner.initialStartDate
          initialStartDate = moment(owner.initialStartDate).format("DD/MM/YYYY")
          self.datePicker.$dateDebit.datepicker('setDate', initialStartDate)
        else
          self.datePicker.$dateDebit.datepicker('clearDates')

  events:
    "keyup .input-field":  (event, template) ->
      if owner = Session.get('transactionOwner')
        if event.target.name is 'initialAmount'
          initialAmount = parseInt(template.ui.$initialAmount.inputmask('unmaskedvalue'))
          if initialAmount isnt (owner.initialAmount ? 0)
            Helpers.deferredAction ->
              Schema.providers.update owner._id, $set:{initialAmount: initialAmount} if owner.model is 'providers'
              Schema.customers.update owner._id, $set:{initialAmount: initialAmount} if owner.model is 'customers'
            , "ownerUpdateInitialAmount"
            , 500

        else if event.target.name is 'initialInterestRate'
          initialInterestRate = parseInt(template.ui.$initialInterestRate.inputmask('unmaskedvalue'))
          if initialInterestRate isnt (owner.initialInterestRate ? 0)
            Helpers.deferredAction ->
              Schema.providers.update owner._id, $set:{initialInterestRate: initialInterestRate} if owner.model is 'providers'
              Schema.customers.update owner._id, $set:{initialInterestRate: initialInterestRate} if owner.model is 'customers'
            , "ownerUpdateInitialInterestRate"
            , 500

    "change [name='dateDebit']": (event, template) ->
      if owner = Session.get('transactionOwner')
        Helpers.deferredAction ->
          initialStartDate = template.datePicker.$dateDebit.datepicker().data().datepicker.dates[0]
          if initialStartDate?.toDateString() isnt (owner.initialStartDate?.toDateString() ? undefined)
            Schema.providers.update owner._id, $set:{initialStartDate: initialStartDate} if owner.model is 'providers'
            Schema.customers.update owner._id, $set:{initialStartDate: initialStartDate} if owner.model is 'customers'
        , "ownerUpdateInitialStartDate"
        , 200