
Enums = Apps.Merchant.Enums
Wings.defineApp 'customerOverview',
  created: ->
    self = this
    self.autorun ()->

  rendered: ->
  destroyed: ->

  helpers:
    dataLists: ->
      dataLists =
        details : []
        overview:
          count        : 0
          debitCash    : 0
          interestCash : 0
          paidCash     : 0
          totalCash    : 0

      currentDynamic = Session.get("reportOptionsCurrentDynamics")
      return dataLists if !currentDynamic

      dataLists.details = _.sortBy(Schema.customers.find({merchant: merchantId ? Merchant.getId()}).fetch(),
        (item) ->
          dataLists.overview.count        += 1
          dataLists.overview.totalCash    += item.totalCash
          dataLists.overview.paidCash     += item.paidCash
          dataLists.overview.debitCash    += item.debitCash
          dataLists.overview.interestCash += item.interestCash
          -item.totalCash
      )
      detail.count = index+1 for detail, index in dataLists.details

      customerSearchText = Session.get('customerOverviewSectionCustomerSearchText')
      if customerSearchText?.length > 0 and  dataLists.details.length > 0
        dataLists.details = _.filter dataLists.details, (customer) ->
          unsignedTerm = Helpers.RemoveVnSigns customerSearchText
          unsignedName = Helpers.RemoveVnSigns customer.name
          unsignedName.indexOf(unsignedTerm) > -1

      dataLists




  events:
    "click .searchCustomer": (event, template) ->
      isSearch = Session.get("customerOverviewSectionSearchCustomer")
      Session.set("customerOverviewSectionSearchCustomer", !isSearch)
      Session.set("customerOverviewSectionCustomerSearchText",'')

    "keyup input[name='searchCustomerFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter = $("input[name='searchCustomerFilter']").val()
        searchFilter = searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," ")
        Session.set("customerOverviewSectionCustomerSearchText", searchFilter)
        Session.set("customerOverviewSectionSearchCustomer", false) if searchFilter.length is 0
      , "customerOverviewSectionCustomerSearchText"
      , 200