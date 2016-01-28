
warehouseOption = [
  group: 'TỔNG QUAN'
  optionChild: -> Option01
,
  group: 'KHO HÀNG'
  optionChild: -> Option02
,
  group: 'KIỂM KHO'
  optionChild: -> Option03
]

Option01 =  [
  display: "sản phẩm"
  icon: "icon-tags"
  template: 'warehouseSummaryAllProduct'
  overview: 'warehouseOverview'
,
  display: "sắp hết hạn"
  icon: "icon-clock"
  template: 'warehouseSummaryProductLastExpire'
  overview: 'warehouseOverview'
,
  display: "sắp hết hàng"
  icon: "icon-dot-3"
  template: 'warehouseSummaryProductLowQuantity'
  overview: 'warehouseOverview'
,
  display: "tồn kho đầu kỳ"
  icon: "icon-cubes"
  template: 'warehouseSummaryProductInventory'
  overview: 'warehouseOverview'
,
  display: "tồn kho đinh mức"
  icon: "icon-database"
  template: 'warehouseSummaryProductLowNorms'
  overview: 'warehouseOverview'
]

Option02 =  [
  display: "tất cả"
  icon: "icon-home-4"
  template: "warehouseAllProduct"
  overview: "warehouseOverview"
,
  display: "có giao dịch"
  icon: "icon-basket"
  template: "warehouseOnlyProductTrade"
  overview: "warehouseOverview"
,
  display: "chưa giao dịch"
  icon: "icon-circle-notch"
  template: "warehouseOnlyProductNotTrade"
  overview: "warehouseOverview"
,
  display: "thu hồi"
  icon: "icon-inbox-1"
  template: "warehouseOnlyReturnProduct"
  overview: "warehouseOverview"
]


Option03 = [
  display: "cân bằn kho"
  icon: "icon-flow-merge"
  template: 'inventory'
  overview: ''
,
  display: "Lịch sử cân bằng"
  icon: "icon-video-alt"
  template: 'inventoryHistory'
  overview: ''
]



Enums = Apps.Merchant.Enums

Wings.defineApp 'warehouseLayout',
  created: ->
    self = this
    self.autorun ()->


#    Session.set "warehouseOptionsCurrentDynamics", warehouseOption[1].optionChild()[0]
    Session.set "warehouseOptionsCurrentDynamics", warehouseOption[0].optionChild()[3]

  rendered: ->
  destroyed: ->

  helpers:
    options: -> warehouseOption
    optionActiveClass: -> if @template is Session.get("warehouseOptionsCurrentDynamics")?.template then 'active' else ''
    currentSectionDynamic: -> Session.get("warehouseOptionsCurrentDynamics")

    isEditRow: ->
      console.log @
      true

    productLists: ->
      productLists =
        details : []
        overview:
          showProductExchange   : false
          showExpireAndQuantity : false
          totalCostPrice        : 0
          totalRevenue          : 0
          totalProduct          : 0
          tradeProductCount     : 0
          notTradeProductCount  : 0
          returnProductCount    : 0
          expireProductCount    : 0
          lowProductCount       : 0
          normsProductCount     : 0
          inventoryProductCount : 0

      currentDynamic = Session.get("warehouseOptionsCurrentDynamics")
      return productLists if !currentDynamic

      productLists.overview.showExpireAndQuantity = _.contains([
        warehouseOption[0].optionChild()[0].template
        warehouseOption[0].optionChild()[1].template
        warehouseOption[0].optionChild()[2].template
        warehouseOption[0].optionChild()[3].template
        warehouseOption[0].optionChild()[4].template
      ], currentDynamic.template)

      productLists.overview.showProductExchange = _.contains([
        warehouseOption[1].optionChild()[0].template
        warehouseOption[1].optionChild()[1].template
        warehouseOption[1].optionChild()[2].template
        warehouseOption[1].optionChild()[3].template
      ], currentDynamic.template)


      productOption = sort: {name: 1}
      productQuery  =
        $and: [
          merchant : merchantId ? Merchant.getId()
          status   : 1
        ]


      Schema.products.find(productQuery, productOption).map(
        (product) ->
          quantity   = product.merchantQuantities[0]
          quality    = product.merchantQuantities[0].inStockQuantity
          quality    = 0 if quality < 0

          costPrice  = quality * product.getPrice(undefined, 'import')
          revenue    = quality * product.getPrice(undefined, 'sale')

          hasProductTrade = quantity.importQuantity > 0 or quantity.saleQuantity > 0

          product.costPrice = costPrice ? 0
          product.revenue   = revenue ? 0

          productLists.overview.totalCostPrice += product.costPrice
          productLists.overview.totalRevenue   += product.revenue
          productLists.overview.totalProduct   += 1

          productLists.overview.tradeProductCount     += 1 if hasProductTrade
          productLists.overview.notTradeProductCount  += 1 if !hasProductTrade
          productLists.overview.returnProductCount    += 1 if quantity.returnSaleQuantity > 0
          productLists.overview.expireProductCount    += 1 if product.lastExpire
          productLists.overview.lowProductCount       += 1 if quantity.importQuantity > 0 and quantity.inStockQuantity < quantity.lowNormsQuantity
          productLists.overview.normsProductCount     += 1 if quantity.lowNormsQuantity > 0
          productLists.overview.inventoryProductCount += 1 if product.inventoryInitial


          if currentDynamic.template is warehouseOption[0].optionChild()[0].template
            product.count = productLists.overview.totalProduct
            productLists.details.push(product)


          else if currentDynamic.template is warehouseOption[0].optionChild()[1].template
            if product.lastExpire
              product.count = productLists.overview.expireProductCount
              productLists.details.push(product)

          else if currentDynamic.template is warehouseOption[0].optionChild()[2].template
            if quantity.importQuantity > 0 and quantity.inStockQuantity < quantity.lowNormsQuantity
              product.count = productLists.overview.lowProductCount
              productLists.details.push(product)


          else if currentDynamic.template is warehouseOption[0].optionChild()[3].template
#            if product.inventoryInitial
#              product.count = productLists.overview.inventoryProductCount
#              productLists.details.push(product)
            product.count = productLists.overview.totalProduct
            productLists.details.push(product)

          else if currentDynamic.template is warehouseOption[0].optionChild()[4].template
            product.count = productLists.overview.totalProduct
            productLists.details.push(product)


          else if currentDynamic.template is warehouseOption[1].optionChild()[0].template
            product.count = productLists.overview.totalProduct
            productLists.details.push(product)


          else if currentDynamic.template is warehouseOption[1].optionChild()[1].template
            if quantity.importQuantity > 0 or quantity.saleQuantity > 0
              product.count = productLists.overview.tradeProductCount
              productLists.details.push(product)


          else if currentDynamic.template is warehouseOption[1].optionChild()[2].template
            if !quantity.importQuantity > 0 and !quantity.saleQuantity > 0
              product.count = productLists.overview.notTradeProductCount
              productLists.details.push(product)


          else if currentDynamic.template is warehouseOption[1].optionChild()[3].template
            if quantity.returnSaleQuantity > 0
              product.count = productLists.overview.returnProductCount
              productLists.details.push(product)


          product
      )

      productSearchText = Session.get('warehouseSectionProductSearchText')
      if productSearchText?.length > 0 and  productLists.details.length > 0
        productSearchLists = _.filter productLists.details, (product) ->
          unsignedTerm = Helpers.RemoveVnSigns productSearchText
          unsignedName = Helpers.RemoveVnSigns product.name
          unsignedName.indexOf(unsignedTerm) > -1

#        (product.count = index + 1) for product, index in productLists
        productLists.details = productSearchLists

      productLists




  events:
    "click .caption.inner": (event, template) ->
      Session.set("warehouseSectionSearchProduct", false)
      Session.get('warehouseSectionProductSearchText', '')
      Session.set("warehouseOptionsCurrentDynamics", @)



    "keyup input[name='searchProductFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter = $("input[name='searchProductFilter']").val()
        searchFilter = searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," ")
        Session.set("warehouseSectionProductSearchText", searchFilter)
        Session.set("warehouseSectionSearchProduct", false) if searchFilter.length is 0
      , "warehouseSectionProductSearchText"
      , 200


    "click .detail-row.editLowNorms": (event, template) ->
      currentDynamic = Session.get("warehouseOptionsCurrentDynamics")
      if currentDynamic.template is warehouseOption[0].optionChild()[4].template
        Session.set("warehouseSummaryProductLowNormsEditId", @_id)
      else
        Session.set("warehouseSummaryProductLowNormsEditId", '')

    "click .detail-row.inventory": (event, template) ->
      currentDynamic = Session.get("warehouseOptionsCurrentDynamics")
      if currentDynamic.template is warehouseOption[0].optionChild()[3].template
        Session.set("warehouseSummaryProductInventoryEditId", @_id)
      else
        Session.set("warehouseSummaryProductInventoryEditId", '')


    "click .searchProduct": (event, template) ->
      isSearch = Session.get("warehouseSectionSearchProduct")
      Session.set("warehouseSectionSearchProduct", !isSearch)
      Session.set("warehouseSectionProductSearchText",'')



