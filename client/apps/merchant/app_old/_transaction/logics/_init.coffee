#Enums = Apps.Merchant.Enums
#scope = logics.transactionManagement = {}
#Module 'logics.transactionManagement',
#  transactionMenus: [
#    display: "khách hàng"
#    icon: "pomegranate icon-users-outline"
#    app: "merchantOptions"
#  ,
#    display: "nhà cung cấp"
#    icon: "carrot icon-location-1"
#    app: "staffManagement"
#  ]
#
#  transactionTypeSelect:
#    query: (query) -> query.callback
#      results: _.filter(Enums.TransactionGroups, (num) -> return num unless num._id is 2)
#      text: '_id'
#    initSelection: (element, callback) -> callback findTransactionGroup(Session.get('transactionManagement')?.data.transactionGroup)
#    formatSelection: (item)-> "#{item.display}" if item
#    formatResult: (item)-> "#{item.display}" if item
#    placeholder: 'Chọn KH Hoặc NCC'
#    minimumResultsForSearch: -1
#    changeAction: (e) ->
#  #        if e.added
#  #          newTransaction = Session.get('transactionDetail')
#  #          if newTransaction.transactionType is Enums.getValue('TransactionTypes', 'provider')
#  #            newTransaction.receivable = if e.added._id then false else true
#  #          else if newTransaction.transactionType is Enums.getValue('TransactionTypes', 'customer')
#  #            newTransaction.receivable = unless e.added._id then false else true
#  #
#  #          delete newTransaction.owner
#  #          newTransaction.transactionType = e.added._id
#  #          Session.set('transactionDetail', newTransaction)
#    reactiveValueGetter: -> findTransactionGroup(Session.get('transactionManagement')?.data.transactionGroup)
#
#  transactionOwnerSelect:
#    query: (query) -> query.callback
#      results: ownerSearch(query.term)
##      results: ->
##        transactionManagement = Session.get('transactionManagement')
##        return [] unless transactionManagement
##
##        selector = merchant: Merchant.getId(); options = {sort: {nameSearch: 1}}
##        if(query.term)
##          regExp = Helpers.BuildRegExp(query.term);
##          selector = {$or: [
##            {nameSearch: regExp, merchant: Merchant.getId()}
##          ]}
##        scope.customerList = Schema.customers.find(selector, options).fetch()
##        scope.customerList
#
#      text: 'name'
#    initSelection: (element, callback) -> callback findTransactionOwner(Session.get('transactionManagement')?.data.owner)
#    formatSelection: (item) -> "#{item.name}" if item
#    formatResult: (item) -> "#{item.name}" if item
#    id: '_id'
#    placeholder: 'Chọn KH hoặc NCC'
#    changeAction: (e) ->
#      if e.added
#        transactionManagement = Session.get('transactionManagement')
#        newTransaction = transactionManagement.data
#        newTransaction.owner = e.added._id
#        Session.set('transactionManagement', transactionManagement)
#    reactiveValueGetter: -> Session.get('transactionManagement')?.data.owner ? 'skyReset'
#
#  transactionOwnerIncomeOrCostSelect:
#    query: (query) -> query.callback
#      results: Enums.TransactionCustomerIncomeOrCost
#      text: '_id'
#    initSelection: (element, callback) -> callback findTransactionReceivable(Session.get('transactionDetail')?.incomeOrCost)
#    formatSelection: (item)-> "#{item.display}" if item
#    formatResult: (item)-> "#{item.display}" if item
#    placeholder: 'Chọn loại phiếu thu chi'
#    minimumResultsForSearch: -1
#    changeAction: (e) ->
#      if e.added
#        console.log e.added
#        transactionManagement = Session.get('transactionManagement')
#        newTransaction = transactionManagement.data
#
#        newTransaction.incomeOrCost = e.added._id
#        if newTransaction.transactionGroup is  Enums.getValue('TransactionGroups', 'customer')
#          if newTransaction.incomeOrCost is 0
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'requiredCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 1
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'beginCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 2
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'saleCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 3
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'incurredCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 4
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'incurredCash')
#            newTransaction.receivable      = true
#
#        else if newTransaction.transactionGroup is  Enums.getValue('TransactionGroups', 'provider')
#          if newTransaction.incomeOrCost is 0
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'requiredCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 1
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'beginCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 2
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'saleCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 3
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'incurredCash')
#            newTransaction.receivable      = false
#          else if newTransaction.incomeOrCost is 4
#            newTransaction.transactionType = Enums.getValue('TransactionTypes', 'incurredCash')
#            newTransaction.receivable      = true
#
#
#        Session.set('transactionManagement', transactionManagement)
#    reactiveValueGetter: -> findTransactionReceivable(Session.get('transactionDetail')?.incomeOrCost)
#
#
#ownerSearch = (textSearch) ->
#  transaction = Session.get('transactionDetail')
#  return [] unless transaction
#
#  selector = merchant: Merchant.getId(); options = {sort: {nameSearch: 1}}
#  if(textSearch)
#    regExp = Helpers.BuildRegExp(textSearch);
#    selector = {$or: [
#      {nameSearch: regExp, merchant: Merchant.getId()}
#    ]}
#  scope.customerList = Schema.customers.find(selector, options).fetch()
#  scope.customerList
#
#findTransactionGroup = (transactionGroup) ->
#  _.findWhere(Enums.TransactionGroups, {_id: transactionGroup})
#
#findTransactionReceivable = (receivable) ->
#  _.findWhere(Enums.TransactionCustomerIncomeOrCost, {_id: receivable})
#
#findTransactionOwner = (ownerId)->
#  _.findWhere(scope.customerList, {_id: ownerId})
