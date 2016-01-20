Enums = Apps.Merchant.Enums
scope = logics.transactionManagement

Wings.defineHyper 'interestRateManager',
  created: ->

  rendered: ->
    decimalOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:4}
    self = this

    $initialRate = self.ui.$interestRateInitial
    $initialRate.inputmask "decimal", decimalOption

#    $loanRate = self.ui.$interestRateLoan
#    $loanRate.inputmask "decimal", decimalOption

    $saleRate = self.ui.$interestRateSale
    $saleRate.inputmask "decimal", decimalOption

    self.autorun ()->
      if interestRates = Session.get('merchant')?.interestRates ? {initial: 0, sale: 0, loan: 0}
        initialRateValue = parseInt($initialRate.inputmask('unmaskedvalue'))
        $initialRate.val interestRates.initial if initialRateValue isnt interestRates.initial

#        loanRateValue = parseInt($loanRate.inputmask('unmaskedvalue'))
#        $loanRate.val interestRates.loan if loanRateValue isnt interestRates.loan

        saleRateValue = parseInt($saleRate.inputmask('unmaskedvalue'))
        $saleRate.val interestRates.sale if saleRateValue isnt interestRates.sale

  events:
    "keyup .input-field":  (event, template) ->
      if merchant = Session.get('merchant')
        if event.target.name is 'interestRateInitial'
          initial = parseInt(template.ui.$interestRateInitial.inputmask('unmaskedvalue'))
          if initial isnt (merchant.interestRates.initial ? 0)
            Schema.merchants.update merchant._id, $set:{'interestRates.initial': initial}
#
#        else if event.target.name is 'interestRateLoan'
#          loan = parseInt(template.ui.$interestRateLoan.inputmask('unmaskedvalue'))
#          if loan isnt (merchant.interestRates.loan ? 0)
#            Schema.merchants.update merchant._id, $set:{'interestRates.loan': loan}

        else if event.target.name is 'interestRateSale'
          sale = parseInt(template.ui.$interestRateSale.inputmask('unmaskedvalue'))
          if sale isnt (merchant.interestRates.sale ? 0)
            Schema.merchants.update merchant._id, $set:{'interestRates.sale': sale}

