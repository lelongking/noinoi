scope = logics.customerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineHyper Template.customerManagementSalesHistorySection,
  helpers:
    currentCustomer: -> Template.currentData()

    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1
    allSales: -> logics.customerManagement.findAllOrders(Template.currentData())
    oldDebts: -> logics.customerManagement.findOldDebtCustomer()

    hasOldDebts: -> logics.customerManagement.findOldDebtCustomer(Template.currentData()).length > 0

    hasDebitBegin: ->
      if @model is "customers"
        (@debtRequiredCash ? 0) + (@debtBeginCash ? 0) isnt 0
      else if Template.parentData()?.model is "customers"
        (Template.parentData().debtRequiredCash ? 0) + (Template.parentData().debtBeginCash ? 0) + (@balanceBefore ? 0) isnt 0



    sumBeforeBalance: ->
      (Template.parentData().debtRequiredCash ? 0) + (Template.parentData().debtBeginCash ? 0) + @balanceBefore ? 0

    sumLatestBalance: ->
      (Template.parentData().debtRequiredCash ? 0) + (Template.parentData().debtBeginCash ? 0) + @balanceLatest ? 0

    sumRequiredAndBeginDebtCash: ->
      if @model is "customers"
        (@debtRequiredCash ? 0) + (@debtBeginCash ? 0)
      else if Template.parentData()?.model is "customers"
        (Template.parentData().debtRequiredCash ? 0) + (Template.parentData().debtBeginCash ? 0)


    transactionDescription: -> if Session.get("customerManagementOldDebt") then 'ghi chú nợ tiền' else 'ghi chú trả tiền'
    transactionStatus: -> if Session.get("customerManagementOldDebt") then 'Nợ Tiền' else 'Trả Tiền'
    showTransaction: -> if Session.get("customerManagementOldDebt") is undefined then 'display: none'

    amountDetails: ->
      currentCustomer = Template.currentData()

      debitCash    = (currentCustomer.initialAmount ? 0) + (currentCustomer.loanAmount ? 0)
      saleCash     = (currentCustomer.saleAmount ? 0) + (currentCustomer.returnPaidAmount ? 0) - (currentCustomer.returnAmount ? 0)
      interestCash = 0
      paidCash     = (currentCustomer.paidAmount ? 0)

      console.log debitCash
      debitCash   : debitCash + saleCash
      interestCash: interestCash
      paidCash    : paidCash
      totalCash   : debitCash + saleCash - paidCash + interestCash


  rendered: ->
    Session.get("customerManagementOldDebt")
    @ui.$paySaleAmount.inputmask("numeric", numericOption) if @ui.$paySaleAmount

  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteNewTransaction', @_id
      event.stopPropagation()

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfCustomer(event, template)
