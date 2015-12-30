scope = logics.customerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

lemon.defineHyper Template.customerManagementSalesHistorySection,
  helpers:
    currentCustomer: -> Template.currentData()

    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1
    allSales: -> logics.customerManagement.findAllOrders(Template.currentData())
    oldDebts: -> logics.customerManagement.findOldDebtCustomer()

    hasOldDebts: -> logics.customerManagement.findOldDebtCustomer(Template.currentData()).length > 0



    sumBeforeBalance: ->
      (Template.parentData().initialAmount ? 0) + @balanceBefore ? 0

    sumLatestBalance: ->
      (Template.parentData().initialAmount ? 0) + @balanceLatest ? 0

    sumRequiredAndBeginDebtCash: ->
      if @model is "customers"
        (@initialAmount ? 0)
      else if Template.parentData()?.model is "customers"
        (Template.parentData().initialAmount ? 0)


    transactionDescription: -> if Session.get("customerManagementOldDebt") then 'ghi chú nợ tiền' else 'ghi chú trả tiền'
    transactionStatus: -> if Session.get("customerManagementOldDebt") then 'Nợ Tiền' else 'Trả Tiền'
    showTransaction: -> if Session.get("customerManagementOldDebt") is undefined then 'display: none'


  rendered: ->
    Session.get("customerManagementOldDebt")
    @ui.$paySaleAmount.inputmask("numeric", numericOption) if @ui.$paySaleAmount

  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id
      event.stopPropagation()

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfCustomer(event, template)
