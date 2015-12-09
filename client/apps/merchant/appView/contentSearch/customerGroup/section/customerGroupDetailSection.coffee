scope = logics.customerGroup
Enums = Apps.Merchant.Enums

Wings.defineHyper 'customerGroupDetailSection',
  helpers:
    selected: -> if _.contains(Session.get("customerSelectLists"), @_id) then 'selected' else ''
    totalCashByStaff: ->
      totalCash = 0
      if scope.customerList
        (totalCash += customer.debtCash + customer.loanCash) for customer in scope.customerList
      totalCash

    customerLists: ->
      console.log @customerLists
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
      scope.customerList = customerList
      customerList

  events:
    "click .detail-row:not(.selected) td.command": (event, template) ->
      scope.currentCustomerGroup.selectedCustomer(@_id) if User.hasManagerRoles()
      event.stopPropagation()

    "click .detail-row.selected td.command": (event, template) ->
      scope.currentCustomerGroup.unSelectedCustomer(@_id) if User.hasManagerRoles()
      event.stopPropagation()

    "click .detail-row": (event, template) ->
      FlowRouter.go('/customer')
      Session.set 'currentOrder', @
      Customer.setSession(@_id)