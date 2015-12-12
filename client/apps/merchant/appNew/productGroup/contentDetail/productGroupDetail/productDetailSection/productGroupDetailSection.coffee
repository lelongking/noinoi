scope = logics.productGroup
Enums = Apps.Merchant.Enums

Wings.defineHyper 'productGroupDetailSection',
  helpers:
    isSearch: -> Session.get("productGroupDetailSectionSearchCustomer")
    selected: -> if _.contains(Session.get("productSelectLists"), @_id) then 'selected' else ''
    totalCashByStaff: ->
      totalCash = 0
      if Session.get("productSelectLists")
        (totalCash += product.debtCash + product.loanCash) for product in Session.get("productSelectLists")
      totalCash

    productLists: ->
      return [] if !@productLists or @productLists.length is 0
      productListId = _.intersection(@productLists, Session.get('myProfile').productLists)
      productQuery = {productOfGroup: @_id}
      productQuery._id = {$in: productListId} unless User.hasManagerRoles()
      productList = Schema.products.find(productQuery,{sort: {name: 1}}).map(
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
#      scope.productList = productList

      productSearchText = Session.get('productGroupDetailSectionCustomerSearchText')
      if productSearchText?.length > 1
        _.filter productList, (product) ->
          unsignedTerm = Helpers.RemoveVnSigns productSearchText
          unsignedName = Helpers.RemoveVnSigns product.name
          unsignedName.indexOf(unsignedTerm) > -1
      else
        productList


  events:
    "click .searchCustomer": (event, template) ->
      isSearch = Session.get("productGroupDetailSectionSearchCustomer")
      Session.set("productGroupDetailSectionSearchCustomer", !isSearch)
      Session.set("productGroupDetailSectionCustomerSearchText",'')

    "keyup input[name='searchCustomerFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = $("input[name='searchCustomerFilter']").val()
        Session.set("productGroupDetailSectionCustomerSearchText", searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," "))
      , "productGroupDetailSectionCustomerSearchText"
      , 100



    "click .detail-row:not(.selected) td.command": (event, template) ->
      template.data.selectedCustomer(@_id)
      event.stopPropagation()

    "click .detail-row.selected td.command": (event, template) ->
      template.data.unSelectedCustomer(@_id)
      event.stopPropagation()


    "click .detail-row": (event, template) ->
      FlowRouter.go('product')
      Session.set 'currentOrder', @
      Customer.setSession(@_id)

