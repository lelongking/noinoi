Wings.defineHyper 'createPaidTransaction',
  created: ->
  rendered: ->
    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits: 11}
    $transactionAmount = self.ui.$transactionAmount
    $transactionAmount.inputmask "integer", integerOption
    $transactionAmount.val ''


  helpers:
    currentOwner: -> Session.get('transactionOwner')
    transaction: -> Session.get('transactionDetail')

  events:
    "keyup .transaction-field":  (event, template) ->
      if transactionDetail = Session.get('transactionDetail')
        if event.target.name is 'transactionAmount'
          transactionDetail.amount = parseInt(template.ui.$transactionAmount.inputmask('unmaskedvalue'))

        else if event.target.name is 'transactionInterestRate'
          transactionDetail.interestRate = parseFloat(template.ui.$transactionInterestRate.inputmask('unmaskedvalue'))
          Session.set('transactionDetail', transactionDetail)

        else if event.target.name is 'transactionDescription'
          transactionDetail.description = template.ui.$transactionDescription.val()
          Session.set('transactionDetail', transactionDetail)

        Session.set('transactionDetail', transactionDetail)