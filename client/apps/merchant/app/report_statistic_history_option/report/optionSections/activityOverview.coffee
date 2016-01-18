
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

  destroyed: ->

  helpers:
    dataLists: ->
      dataLists =
        details : []
        overview:
          totalCosts  : 0
          totalSales  : 0
          totalProfits: 0

      dateRange      = Session.get('reportOptionsDateRange')
      currentDynamic = Session.get("reportOptionsCurrentDynamics")
      return dataLists if !currentDynamic


      importLists = Schema.imports.find({
        merchant    : merchantId ? Merchant.getId()
        importType  : Enums.getValue('ImportTypes', 'success')
        successDate : {$gte: dateRange.startDate, $lte: dateRange.endDate}
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
          dataLists.overview.totalCosts   += detail.finalPrice
          dataLists.overview.totalProfits -= detail.finalPrice
        else if detail.model is 'orders'
          dataLists.overview.totalSales   += detail.finalPrice
          dataLists.overview.totalProfits += detail.finalPrice


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