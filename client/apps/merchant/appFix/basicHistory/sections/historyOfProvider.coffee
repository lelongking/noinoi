scope = logics.basicHistory = {}

Wings.defineApp 'historyOfProvider',
  created: ->
    Session.set('revenueBasicAreaReportView', 'totalCash')

  helpers:
    isDisabled: -> Session.get("basicHistoryDynamics")?.name is 'providerGroup'
    sumCash : -> scope.sumCash
    providerLists: ->
      scope.sumCash =
        sumDebtRequiredCash : 0
        sumPaidRequiredCash : 0

        sumDebtBeginCash    : 0
        sumPaidBeginCash    : 0

        sumDebtIncurredCash : 0
        sumPaidIncurredCash : 0

        sumDebtSaleCash     : 0
        sumReturnSaleCash   : 0

        sumTurnoverCash     : 0
        sumPaidSaleCash     : 0
        sumTotalCash        : 0

        sumBeginCash    : 0
        sumDebtCash     : 0
        sumReturnCash   : 0
        sumPaidCash     : 0


      selector = {}; merchantId = Merchant.getId(); scope.providerLists = []
      if searchText = Session.get('basicHistoryProviderSearchText')
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [{customerCode: regExp, merchant: merchantId}, {nameSearch: regExp, merchant: merchantId}]}


      Schema.providers.find(selector, {sort: {nameSearch: 1}}).forEach(
        (provider) ->
          scope.sumCash.sumDebtRequiredCash += provider.debtRequiredCash
          scope.sumCash.sumPaidRequiredCash += provider.paidRequiredCash
          scope.sumCash.sumDebtBeginCash    += provider.debtBeginCash
          scope.sumCash.sumPaidBeginCash    += provider.paidBeginCash
          scope.sumCash.sumDebtIncurredCash += provider.debtIncurredCash
          scope.sumCash.sumPaidIncurredCash += provider.paidIncurredCash
          scope.sumCash.sumDebtSaleCash     += provider.debtSaleCash
          scope.sumCash.sumReturnSaleCash   += provider.returnSaleCash
          scope.sumCash.sumTurnoverSaleCash += provider.turnoverSaleCash
          scope.sumCash.sumPaidSaleCash     += provider.paidSaleCash
          scope.sumCash.sumTotalCash        += provider.totalCash()

          scope.providerLists.push(provider)
      )
      scope.providerLists



  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = $("input[name='searchFilter']").val()
        Session.set("basicHistoryProviderSearchText", searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," "))
      , "basicHistorySearchSearchProvider"
      , 100

    "keyup input.debtRequiredCash":  (event, template) ->
      provider = @
      Helpers.deferredAction ->
        if provider
          debtRequiredCash = $("[name=#{provider._id}].debtRequiredCash").val()
          debtRequiredCash = Math.abs(accounting.unformat(debtRequiredCash))
          Schema.providers.update(provider._id, {$set:{debtRequiredCash: debtRequiredCash}})
      , "basicHistoryChangeDebtRequiredCash"
      , 500

    "keyup input.debtBeginCash":  (event, template) ->
      provider = @
      Helpers.deferredAction ->
        if provider
          debtBeginCash = $("[name=#{provider._id}].debtBeginCash").val()
          debtBeginCash = Math.abs(accounting.unformat(debtBeginCash))
          Schema.providers.update(provider?._id, {$set:{debtBeginCash: debtBeginCash}})
      , "basicHistoryChangeDebtBeginCash"
      , 500