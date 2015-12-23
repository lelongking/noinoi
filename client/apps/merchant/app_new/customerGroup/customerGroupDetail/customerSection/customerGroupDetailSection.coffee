scope = logics.customerGroup
Enums = Apps.Merchant.Enums

Wings.defineHyper 'customerGroupDetailSection',
  helpers:
    isSearch: -> Session.get("customerGroupDetailSectionSearchCustomer")
    selected: -> if _.contains(Session.get("customerSelectLists"), @_id) then 'selected' else ''
    totalCashByStaff: ->
      totalCash = 0
      if Session.get("customerSelectLists")
        (totalCash += customer.debtCash + customer.loanCash) for customer in Session.get("customerSelectLists")
      totalCash

    customerLists: ->
      return [] if !@customerLists or @customerLists.length is 0
      customerListId = _.intersection(@customerLists, Session.get('myProfile').customerLists)
      customerQuery = {customerOfGroup: @_id}
      customerQuery._id = {$in: customerListId} unless User.hasManagerRoles()
      customerList = Schema.customers.find(customerQuery,{sort: {name: 1}}).map(
        (item) ->
          order = Schema.orders.findOne({
            buyer       : item._id
            orderType   : Enums.getValue('OrderTypes', 'success')
            orderStatus : Enums.getValue('OrderStatus', 'finish')
          })
          if order
            item.latestTradingDay       = order.successDate
            item.latestTradingTotalCash = accounting.formatNumber(order.finalPrice) + ' VND'

          item.debtTotalCash = accounting.formatNumber(item.debtCash + item.loanCash) + ' VND'
          item
      )
#      scope.customerList = customerList

      customerSearchText = Session.get('customerGroupDetailSectionCustomerSearchText')
      if customerSearchText?.length > 1
        _.filter customerList, (customer) ->
          unsignedTerm = Helpers.RemoveVnSigns customerSearchText
          unsignedName = Helpers.RemoveVnSigns customer.name
          unsignedName.indexOf(unsignedTerm) > -1
      else
        customerList


  events:
    "click .searchCustomer": (event, template) ->
      isSearch = Session.get("customerGroupDetailSectionSearchCustomer")
      Session.set("customerGroupDetailSectionSearchCustomer", !isSearch)
      Session.set("customerGroupDetailSectionCustomerSearchText",'')

    "keyup input[name='searchCustomerFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = $("input[name='searchCustomerFilter']").val()
        Session.set("customerGroupDetailSectionCustomerSearchText", searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," "))
      , "customerGroupDetailSectionCustomerSearchText"
      , 100



    "click .detail-row:not(.selected) td.command": (event, template) ->
      template.data.selectedCustomer(@_id)
      event.stopPropagation()

    "click .detail-row.selected td.command": (event, template) ->
      template.data.unSelectedCustomer(@_id)
      event.stopPropagation()


    "click .detail-row": (event, template) ->
      FlowRouter.go('customer')
      Session.set 'currentOrder', @
      Customer.setSession(@_id)

