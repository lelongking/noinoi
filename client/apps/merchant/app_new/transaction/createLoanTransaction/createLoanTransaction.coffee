Wings.defineHyper 'createLoanTransaction',
  created: ->
  rendered: ->
    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits: 11}
    $transactionAmount = self.ui.$transactionAmount
    $transactionAmount.inputmask "integer", integerOption
    $transactionAmount.val 0


    decimalOption        = {autoGroup: true, groupSeparator:",", radixPoint: ".", integerDigits:4}
    $transactionInterestRate = self.ui.$transactionInterestRate
    $transactionInterestRate.inputmask "decimal", decimalOption
    $transactionInterestRate.val 0