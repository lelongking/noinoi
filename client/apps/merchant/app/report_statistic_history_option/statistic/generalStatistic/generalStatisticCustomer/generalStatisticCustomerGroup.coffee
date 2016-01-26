scope = {}
newCashGroup = -> {requiredCash: 0, beginCash: 0, incurredCash: 0, saleCash: 0, totalCash: 0}
formatMoney = (value, symbol = '', precision = 3)->
  accounting.formatMoney(value, "", precision, ".", ",") + (if symbol then ' ' + symbol else '')

Wings.defineApp 'generalStatisticCustomerGroup',
  created: ->
    console.log Template.instance()
    console.log Template.currentData().customerGroups
    scope.customerGroupLists = []
    Schema.customerGroups.find({}).forEach(
      (customerGroup) ->
        scope.customerGroupLists.push({
          _id          : customerGroup._id
          name         : customerGroup.name
          requiredCash : customerGroup.requiredCash/1000000
          beginCash    : customerGroup.beginCash/1000000
          incurredCash : customerGroup.incurredCash/1000000
          saleCash     : customerGroup.saleCash/1000000
          totalCash    : customerGroup.totalCash/1000000
        })
    )
    scope.customerGroupLists = _.sortBy(scope.customerGroupLists, 'totalCash')


  rendered: ->
    scope.revenueOfAreaReport =
      c3.generate
        bindto: '#revenueOfAreaReport'
        size:
          height: (30*scope.customerGroupLists.length+55)

        data:
          json: scope.customerGroupLists
          names:
            totalCash: 'Tổng Nợ'
#            beginCash   : 'Nợ Đầu Kỳ'
#            incurredCash: 'Phát Sinh Khác'
#            saleCash    : 'Bán Hàng'
#          groups: [['requiredCash'
#                    'beginCash'
#                    'incurredCash'
#                    'saleCash']]
          keys:
            x: 'name'
            value: ['totalCash']


          type: 'bar'
          labels:
            format:
              totalCash: (value, id, i, j)-> if value isnt 0 then formatMoney(value, 'Tr') else ''
#              beginCash   : (value, id, i, j)-> if value isnt 0 then formatMoney(value, 'Tr') else ''
#              incurredCash: (value, id, i, j)-> if value isnt 0 then formatMoney(value, 'Tr') else ''
#              saleCash    : (value, id, i, j)-> if value isnt 0 then formatMoney(value, 'Tr') else ''

        axis:
          rotated: true
          x: type: 'category'

        tooltip:
          format:
#            title: (d) ->
#              name         = scope.customerGroupLists[d].name
#              totalCash    = scope.customerGroupLists[d].totalCash ? 0
#              totalAllCash = scope.customerGroupLists[d].totalAllCash ? 0
#              cashPercent  = (totalCash*100/totalAllCash).toFixed(2)
#
#              totalCashFormat    = formatMoney totalCash
#              totalAllCashFormat = formatMoney totalAllCash
#              name + ' - ' + cashPercent + '% ' + '(' + totalCashFormat + '/' + totalAllCashFormat + ')'
            value: (value, ratio, id) -> formatMoney value, 'Tr'

  destroyed: ->
    scope.revenueOfAreaReport.destroy()

  helpers:
    areaSelectOptions: ->
      query: (query) -> query.callback
        results: customerGroupSearch(query)
        text: 'name'
      initSelection: (element, callback) -> callback Session.get("basicReportDynamics")?.data
      formatSelection: (item) -> "#{item.name}" if item
      formatResult: (item) -> "#{item.name}" if item
      id: '_id'
      placeholder: 'CHỌN NHÓM'
      changeAction: (e) ->
#        basicReport      = Session.get("basicReportDynamics")
#        basicReport.data = e.added
#        Session.set("basicReportDynamics", basicReport)
        renderChart(e.added)

      reactiveValueGetter: -> Session.get("basicReportDynamics")?.data

customerGroupSearch = (query) ->
  selector = {merchant: Merchant.getId(), totalCash: {$gt: 0}}; options = {sort: {nameSearch: 1}}
  if(query.term)
    regExp = Helpers.BuildRegExp(query.term);
    selector = {$or: [
      {nameSearch: regExp, merchant: Merchant.getId(), totalCash: {$gt: 0}}
    ]}
  groupLists = Schema.customerGroups.find(selector, options).fetch()
  groupLists


renderChart = (group)->
  scope.customerLists = []
  for customer in Schema.customers.find({customerOfGroup: group._id}).fetch()
    scope.customerLists.push({
      _id          : customer._id
      name         : customer.name
      totalCash    : customer.totalCash/1000000
    })

  scope.customerLists = _.sortBy(scope.customerLists, 'totalCash')
  console.log scope.customerLists


  c3.generate
    bindto: '#revenueOfAreaReport'
    size:
      height: (30*scope.customerLists.length+55)

    data:
      json: scope.customerLists
      names:
        totalCash: 'Nợ Phải Thu'
      groups: [['totalCash']]
      keys:
        x: 'name'
        value: ['totalCash']


      type: 'bar'
      labels:
        format:
          totalCash: (value, id, i, j)-> if value isnt 0 then formatMoney(value, 'Tr') else ''

    axis:
      rotated: true
      x: type: 'category'

    tooltip:
      format:
#        title: (d) ->
#          console.log d
#          name         = scope.customerLists[d].name
#          totalCash    = scope.customerLists[d].totalCash ? 0
#          totalAllCash = scope.customerLists[d].totalAllCash ? 0
#          cashPercent  = (totalCash*100/totalAllCash).toFixed(2)
#
#          totalCashFormat    = formatMoney totalCash
#          totalAllCashFormat = formatMoney totalAllCash
#          name + ' - ' + cashPercent + '% ' + '(' + totalCashFormat + '/' + totalAllCashFormat + ')'
        value: (value, ratio, id) -> formatMoney value, 'Tr'