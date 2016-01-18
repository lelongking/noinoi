
Enums = Apps.Merchant.Enums
Wings.defineApp 'saleOverview',
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
        groups : []
        overview:
          totalCosts  : 0
          totalSales  : 0
          totalProfits: 0

      dateRange      = Session.get('reportOptionsDateRange')
      currentDynamic = Session.get("reportOptionsCurrentDynamics")
      return dataLists if !currentDynamic


      orderLists = Schema.orders.find({
        merchant    : merchantId ? Merchant.getId()
        orderType   : Enums.getValue('OrderTypes', 'success')
        orderStatus : Enums.getValue('OrderStatus', 'finish')
        successDate : {$gte: dateRange.startDate, $lte: dateRange.endDate}
      }, {sort:{successDate: -1}}).map(
        (item) ->
          item.activity = 'Bán Hàng'
          item.owner    = Schema.customers.findOne({_id: item.buyer})
          item.code     = item.orderCode
          item.sortDate = item.successDate
          item
      )

      if orderLists.length > 0
        for key, value of _.groupBy(orderLists, (item) -> moment(item.sortDate).format('MM/YYYY'))
          totalCash = 0
          for item, index in value
            item.count = index+1
            totalCash += item.finalPrice
          dataLists.groups.push({description: 'BÁN HÀNG THÁNG ' + key, details: value, totalCash: totalCash})
      else
        dataLists.groups.push({description: 'BÁN HÀNG THÁNG ' + moment().format('MM/YYYY'), details: [], totalCash: 0})
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