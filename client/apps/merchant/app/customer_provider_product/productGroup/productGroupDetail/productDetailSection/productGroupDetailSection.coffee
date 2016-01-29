scope = logics.productGroup
Enums = Apps.Merchant.Enums

Wings.defineHyper 'productGroupDetailSection',
  helpers:
    isSearch: -> Session.get("productGroupDetailSectionSearchProduct")
    selected: -> if _.contains(Session.get("productSelectLists"), @_id) then 'selected' else ''
    totalCashByStaff: ->
      totalCash = 0
      if Session.get("productSelectLists")
        (totalCash += product.debtCash + product.loanCash) for product in Session.get("productSelectLists")
      totalCash

    productLists: ->
      return [] if !@products or @products.length is 0
      productListId = _.intersection(@products, Session.get('myProfile').productSelected)
      productQuery = {productOfGroup: @_id}
      productQuery._id = {$in: productListId} unless User.hasManagerRoles()
      productList = Schema.products.find(productQuery,{sort: {name: 1}}).map(
        (item) ->
#          order = Schema.orders.findOne({
#            buyer       : item._id
#            orderType   : Enums.getValue('OrderTypes', 'success')
#            orderStatus : Enums.getValue('OrderStatus', 'finish')
#          })
#          if order
#            item.latestTradingDay       = order.successDate
#            item.latestTradingTotalCash = accounting.formatNumber(order.finalPrice) + ' VNĐ'
#
#          item.debtTotalCash = accounting.formatNumber(item.debtCash + item.loanCash) + ' VNĐ'
          item
      )
#      scope.productList = productList

      productSearchText = Session.get('productGroupDetailSectionProductSearchText')
      if productSearchText?.length > 0
        _.filter productList, (product) ->
          unsignedTerm = Helpers.RemoveVnSigns productSearchText
          unsignedName = Helpers.RemoveVnSigns product.name
          unsignedName.indexOf(unsignedTerm) > -1
      else
        productList


  events:
    "click .searchProduct": (event, template) ->
      isSearch = Session.get("productGroupDetailSectionSearchProduct")
      Session.set("productGroupDetailSectionSearchProduct", !isSearch)
      Session.set("productGroupDetailSectionProductSearchText",'')

    "keyup input[name='searchProductFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = $("input[name='searchProductFilter']").val()
        Session.set("productGroupDetailSectionProductSearchText", searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," "))
      , "productGroupDetailSectionProductSearchText"
      , 100



    "click .detail-row:not(.selected) td.command": (event, template) ->
      template.data.selectedProduct(@_id)
      event.stopPropagation()

    "click .detail-row.selected td.command": (event, template) ->
      template.data.unSelectedProduct(@_id)
      event.stopPropagation()


    "click .detail-row": (event, template) ->
      FlowRouter.go('product')
      Session.set 'currentProduct', @
      Product.setSession(@_id)

