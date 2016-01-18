activityOption =  [
  display: "tổng quan"
  icon: "icon-tags"
  template: 'activityOverview'
  overview: 'reportOverview'
,
  display: "nhập kho"
  icon: "icon-clock"
  template: 'reportSummaryProductLastExpire'
  overview: 'reportOverview'
,
  display: "trả nhập"
  icon: "icon-dot-3"
  template: 'reportSummaryProductLowQuantity'
  overview: 'reportOverview'
,
  display: "bán hàng"
  icon: "icon-database"
  template: 'reportSummaryProductLowNorms'
  overview: 'reportOverview'
,
  display: "trả bán"
  icon: "icon-database"
  template: 'reportSummaryProductLowNorms'
  overview: 'reportOverview'
]

transactionOption =  [
  display: "khách hàng"
  icon: "icon-home-4"
  template: "reportAllProduct"
  overview: "reportOverview"
,
  display: "nhóm khách hàng"
  icon: "icon-basket"
  template: "reportOnlyProductTrade"
  overview: "reportOverview"
,
  display: "nhà cung cấp"
  icon: "icon-circle-notch"
  template: "reportOnlyProductNotTrade"
  overview: "reportOverview"
]

reportOption = [
  group: 'HOẠT ĐÔNG NHẬP XUẤT'
  optionChild: activityOption
,
  group: 'CÔNG NỢ'
  optionChild: transactionOption
]

Enums = Apps.Merchant.Enums

Wings.defineApp 'reportLayout',
  created: ->
    self = this
    self.autorun ()->


    Session.set "reportOptionsCurrentDynamics", reportOption[0].optionChild[0]

  rendered: ->
  destroyed: ->

  helpers:
    options: -> reportOption
    optionActiveClass: -> if @template is Session.get("reportOptionsCurrentDynamics")?.template then 'active' else ''
    currentSectionDynamic: -> Session.get("reportOptionsCurrentDynamics")

    isEditRow: ->
      console.log @
      true

    productLists: ->
      dataLists =
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

          totalCosts        : 0
          totalSales        : 0
          totalProfits      : 0

      currentDynamic = Session.get("reportOptionsCurrentDynamics")
      return dataLists if !currentDynamic

      dataLists.overview.showExpireAndQuantity = _.contains([
        reportOption[0].optionChild[0].template
        reportOption[0].optionChild[1].template
        reportOption[0].optionChild[2].template
        reportOption[0].optionChild[3].template
        reportOption[0].optionChild[4].template
      ], currentDynamic.template)

      dataLists.overview.showProductExchange = _.contains([
        reportOption[1].optionChild[0].template
        reportOption[1].optionChild[1].template
        reportOption[1].optionChild[2].template
      ], currentDynamic.template)


      productOption = sort: {name: 1}
      productQuery  =
        $and: [
          merchant : merchantId ? Merchant.getId()
          status   : 1
        ]


      importLists = Schema.imports.find({
        merchant  : merchantId ? Merchant.getId()
        importType: Enums.getValue('ImportTypes', 'success')
      }, {}).map(
        (item) ->
          item.activity = 'Nhập Kho'
          item.owner    = Schema.providers.findOne({_id: item.provider})
          item.code     = item.importCode
          item.sortDate = item.successDate
          item
      )
      orderLists  = Schema.orders.find({
        merchant    : merchantId ? Merchant.getId()
        orderType   : Enums.getValue('OrderTypes', 'success')
        orderStatus : Enums.getValue('OrderStatus', 'finish')
      }, {}).map(
        (item) ->
          item.activity = 'Bán Hàng'
          item.owner    = Schema.customers.findOne({_id: item.buyer})
          item.code     = item.orderCode
          item.sortDate = item.successDate
          item
      )
      returnLists = Schema.returns.find({
        merchant    : merchantId ? Merchant.getId()
        returnStatus: Enums.getValue('ReturnStatus', 'success')
      }, {}).map(
        (item) ->
          if item.returnType is Enums.getValue('ReturnTypes', 'customer')
            item.activity = 'Trả Bán'
            item.owner    = Schema.customers.findOne({_id: item.owner})

          else if item.returnType is Enums.getValue('ReturnTypes', 'provider')
            item.activity = 'Trả Nhập'
            item.owner    = Schema.providers.findOne({_id: item.owner})

          item.code     = item.returnCode
          item.sortDate = item.successDate
          item
      )

      dataLists.details = _.sortBy(importLists.concat(orderLists).concat(returnLists), (item) -> item.sortDate )
      (detail.count = index+1) for detail, index in dataLists.details

      productSearchText = Session.get('reportSectionProductSearchText')
      if productSearchText?.length > 0 and  dataLists.details.length > 0
        dataSource = _.filter dataLists.details, (product) ->
          unsignedTerm = Helpers.RemoveVnSigns productSearchText
          unsignedName = Helpers.RemoveVnSigns product.name
          unsignedName.indexOf(unsignedTerm) > -1

#        (product.count = index + 1) for product, index in productLists
        dataLists.details = dataSource

      dataLists




  events:
    "click .caption.inner": (event, template) ->
      Session.set("reportSectionSearchProduct", false)
      Session.get('reportSectionProductSearchText', '')
      Session.set("reportOptionsCurrentDynamics", @)



    "keyup input[name='searchProductFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter = $("input[name='searchProductFilter']").val()
        searchFilter = searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," ")
        Session.set("reportSectionProductSearchText", searchFilter)
        Session.set("reportSectionSearchProduct", false) if searchFilter.length is 0
      , "reportSectionProductSearchText"
      , 200


    "click .detail-row": (event, template) ->
      currentDynamic = Session.get("reportOptionsCurrentDynamics")
      if currentDynamic.template is reportOption[0].optionChild[3].template
        Session.set("reportSummaryProductLowNormsEditId", @_id)
      else
        Session.set("reportSummaryProductLowNormsEditId", '')


    "click .searchProduct": (event, template) ->
      isSearch = Session.get("reportSectionSearchProduct")
      Session.set("reportSectionSearchProduct", !isSearch)
      Session.set("reportSectionProductSearchText",'')



