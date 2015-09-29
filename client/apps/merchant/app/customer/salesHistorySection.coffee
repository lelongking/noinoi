scope = logics.customerManagement
numericOption = {autoGroup: true, groupSeparator:",", radixPoint: ".", suffix: " VNĐ", integerDigits:11}

Wings.defineHyper 'customerManagementSalesHistorySection',
  rendered: ->
    Session.get("customerManagementOldDebt")
    @ui.$paySaleAmount.inputmask("numeric", numericOption) if @ui.$paySaleAmount


  helpers:
    isDelete: -> moment().diff(@version.createdAt ? new Date(), 'days') < 1
    allSales: -> logics.customerManagement.findAllOrders(Template.currentData())
    findOldDebts: ->
      found = logics.customerManagement.findOldDebtCustomer(Template.currentData())
      return {
        hasOldDebts: found.length > 0
        oldDebts: found
      }

    totalDebtCash: ->
      if customer = Session.get('customerManagementCurrentCustomer')
        customer.debtCash + customer.loanCash
      else 0

    totalPaidCash: ->
      if customer = Session.get('customerManagementCurrentCustomer')
        (unless customer.paidCash is undefined then customer.paidCash else 0) + (unless customer.returnCash is undefined then customer.returnCash else 0)
      else 0

    transactionDescription: -> if Session.get("customerManagementOldDebt") then 'ghi chú nợ tiền' else 'ghi chú trả tiền'
    transactionStatus: -> if Session.get("customerManagementOldDebt") then 'Nợ Tiền' else 'Trả Tiền'
    showTransaction: -> if Session.get("customerManagementOldDebt") is undefined then 'display: none'


  events:
    "keyup input.transaction-field":  (event, template) ->
      scope.checkAllowCreateAndCreateTransaction(event, template)

    "click .deleteTransaction": (event, template) ->
      Meteor.call 'deleteTransaction', @_id
      event.stopPropagation()

    "click .createTransaction": (event, template) ->
      scope.createTransactionOfCustomer(event, template)
