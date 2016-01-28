
Enums = Apps.Merchant.Enums
Wings.defineApp 'activityOverview',
  created: ->
    self = this
    self.autorun ()->
    Session.set "reportOptionsDateRange", {
      startDate   : moment(Session.get('merchant')?.version.createdAt).startOf('day')._d
      endDate     : moment().endOf('day')._d
    }


  rendered: ->
    Session.set "reportOptionsDateRange", {
      startDate   : moment(Session.get('merchant')?.version.createdAt ? new Date()).startOf('day')._d
      endDate     : moment().endOf('day')._d
    }

    $("[name=startDate]").datepicker('setDate', Session.get('reportOptionsDateRange').startDate)
    $("[name=endDate]").datepicker('setDate', Session.get('reportOptionsDateRange').endDate)
#
#    $(window).resize ->
#      $("#activityOverviewSection").css('height', $("#activityTable").outerHeight())



  destroyed: ->

  helpers:
    dataLists: ->
      dataLists =
        details : []
        overview:
          totalCosts    : 0
          inventoryCosts: 0
          importCosts   : 0
          underCosts    : 0
          sales         : 0
          salesCosts    : 0
          salesProfits  : 0

      dateRange      = Session.get('reportOptionsDateRange')
      currentDynamic = Session.get("reportOptionsCurrentDynamics")
      return dataLists if !currentDynamic


      importLists = Schema.imports.find({
        $and: [
          merchant    : merchantId ? Merchant.getId()
          finalPrice  : {$gt: 0}
        ,
          $or: [
            importType  : Enums.getValue('ImportTypes', 'success')
            successDate : {$gte: dateRange.startDate, $lte: dateRange.endDate}
          ,
            importType          : Enums.getValue('ImportTypes', 'inventorySuccess')
            'version.createdAt' : {$gte: dateRange.startDate, $lte: dateRange.endDate}
          ]
        ]
      }, {}).map(
        (item) ->
          if item.importType is Enums.getValue('ImportTypes', 'success')
            item.activity = 'Nhập Kho'
            item.owner    = Schema.providers.findOne({_id: item.provider})
          else
            item.activity = 'Đầu Kỳ'
            item.owner    = Schema.products.findOne({_id: item.details[0].product})

          item.code     = item.importCode
          item.sortDate = item.successDate ? item.version.createdAt
          item
      )
      orderLists  = Schema.orders.find({
        merchant    : merchantId ? Merchant.getId()
        orderType   : Enums.getValue('OrderTypes', 'success')
        orderStatus : Enums.getValue('OrderStatus', 'finish')
        successDate : {$gte: dateRange.startDate, $lte: dateRange.endDate}
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
        successDate : {$gte: dateRange.startDate, $lte: dateRange.endDate}
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

      dataLists.details = _.sortBy(importLists.concat(orderLists).concat(returnLists), (item) -> -item.sortDate )

      for detail, index in dataLists.details
        detail.count = index+1
        if detail.model is 'imports'
          dataLists.overview.totalCosts += detail.finalPrice
          if detail.importType is Enums.getValue('ImportTypes', 'success')
            dataLists.overview.importCosts += detail.finalPrice
          else if detail.importType is Enums.getValue('ImportTypes', 'inventorySuccess')
            dataLists.overview.inventoryCosts += detail.finalPrice

        else if detail.model is 'orders'
          dataLists.overview.sales        += detail.finalPrice
          dataLists.overview.salesProfits += detail.finalPrice
          for item in detail.details
            product = Schema.products.findOne({_id: item.product})
            salesCost = product.getPrice(detail.owner, 'import')
            dataLists.overview.salesCosts   += salesCost
            dataLists.overview.salesProfits += -salesCost
            if !product.inventoryInitial
              dataLists.overview.underCosts += salesCost
              dataLists.overview.totalCosts += salesCost


#        else if detail.model is 'returns'


#totalCosts    : 0
#inventoryCosts: 0
#importCosts   : 0
#underCosts    : 0

#sales         : 0
#salesCosts    : 0
#salesProfits  : 0


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
    "change": (event, template) ->
      dateRange = Session.get('reportOptionsDateRange')
      if event.target.name is 'startDate'
        getStartDate = template.datePicker.$startDate.data('datepicker').dates[0]
        if moment(dateRange.startDate).format('DD/MM/YYYY') isnt moment(getStartDate).format('DD/MM/YYYY')
          dateRange.startDate = moment(getStartDate).startOf('day')._d
          Session.set('reportOptionsDateRange', dateRange)

      else if event.target.name is 'endDate'
        getEndDate = template.datePicker.$endDate.data('datepicker').dates[0]
        if moment(dateRange.endDate).format('DD/MM/YYYY') isnt moment(getEndDate).format('DD/MM/YYYY')
          dateRange.endDate = moment(getEndDate).endOf('day')._d
          Session.set('reportOptionsDateRange', dateRange)