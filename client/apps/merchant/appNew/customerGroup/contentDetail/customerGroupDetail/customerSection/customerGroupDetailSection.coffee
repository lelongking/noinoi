scope = logics.customerGroup
Enums = Apps.Merchant.Enums

Wings.defineHyper 'customerGroupDetailSection',
  helpers:
    isSearch: -> Session.get("customerGroupDetailSectionSearchProduct")
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

      customerSearchText = Session.get('customerGroupDetailSectionProductSearchText')
      if customerSearchText?.length > 1
        _.filter customerList, (customer) ->
          unsignedTerm = Helpers.RemoveVnSigns customerSearchText
          unsignedName = Helpers.RemoveVnSigns customer.name
          unsignedName.indexOf(unsignedTerm) > -1
      else
        customerList


  events:
    "click .searchProduct": (event, template) ->
      isSearch = Session.get("customerGroupDetailSectionSearchProduct")
      Session.set("customerGroupDetailSectionSearchProduct", !isSearch)
      Session.set("customerGroupDetailSectionProductSearchText",'')

    "keyup input[name='searchProductFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = $("input[name='searchProductFilter']").val()
        Session.set("customerGroupDetailSectionProductSearchText", searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," "))
      , "customerGroupDetailSectionProductSearchText"
      , 100



    "click .detail-row:not(.selected) td.command": (event, template) ->
      template.data.selectedProduct(@_id)
      event.stopPropagation()

    "click .detail-row.selected td.command": (event, template) ->
      template.data.unSelectedProduct(@_id)
      event.stopPropagation()


    "click .detail-row": (event, template) ->
      FlowRouter.go('customer')
      Session.set 'currentOrder', @
      Product.setSession(@_id)

