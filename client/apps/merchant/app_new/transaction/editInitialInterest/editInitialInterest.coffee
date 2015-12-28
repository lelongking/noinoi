Wings.defineHyper 'editInitialInterest',
  created: ->

  rendered: ->
    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits: 11}
    $initialAmount = self.ui.$initialAmount
    $initialAmount.inputmask "integer", integerOption
    $initialAmount.val 0

    decimal = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:4}
    $initialInterestRate = self.ui.$initialInterestRate
    $initialInterestRate.inputmask "decimal", decimal
    $initialInterestRate.val 0


    self.autorun ()->
      if customer = Session.get('transactionCustomerOwner')
        initialAmountValue = parseInt($initialAmount.inputmask('unmaskedvalue'))
        if initialAmountValue isnt (customer.initialAmount ? 0)
          $initialAmount.val (customer.initialAmount ? 0)

        initialInterestRateValue = parseInt($initialInterestRate.inputmask('unmaskedvalue'))
        if initialInterestRateValue isnt (customer.initialInterestRate ? 0)
          $initialInterestRate.val (customer.initialInterestRate ? 0)

        if customer.initialStartDate
          initialStartDate = moment(customer.initialStartDate).format("DD/MM/YYYY")
          self.datePicker.$dateDebit.datepicker('setDate', initialStartDate)
        else
          self.datePicker.$dateDebit.datepicker('clearDates')

  events:
    "keyup .input-field":  (event, template) ->
      if customer = Session.get('transactionCustomerOwner')
        if event.target.name is 'initialAmount'
          initialAmount = parseInt(template.ui.$initialAmount.inputmask('unmaskedvalue'))
          if initialAmount isnt (customer.initialAmount ? 0)
            Schema.customers.update customer._id, $set:{initialAmount: initialAmount}

        else if event.target.name is 'initialInterestRate'
          initialInterestRate = parseInt(template.ui.$initialInterestRate.inputmask('unmaskedvalue'))
          if initialInterestRate isnt (customer.initialInterestRate ? 0)
            Schema.customers.update customer._id, $set:{initialInterestRate: initialInterestRate}

    "change [name='dateDebit']": (event, template) ->
      if customer = Session.get('transactionCustomerOwner')
        Helpers.deferredAction ->
          initialStartDate = template.datePicker.$dateDebit.datepicker().data().datepicker.dates[0]
          if initialStartDate?.toDateString() isnt (customer.initialStartDate?.toDateString() ? undefined)
            Schema.customers.update customer._id, $set:{initialStartDate: initialStartDate}
        , "customerUpdateInitialStartDate"
        , 200