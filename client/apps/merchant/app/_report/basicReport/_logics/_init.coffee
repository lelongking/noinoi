logics.basicReport = {}
Apps.Merchant.basicReportInit = []
Apps.Merchant.basicReportReactive = []

Apps.Merchant.basicReportReactive.push (scope) ->

Apps.Merchant.basicReportInit.push (scope) ->
#  scope.revenueOfArea =
#    nv.models.pieChart()
#      .x((d) -> d.name )
#      .y((d) -> d.totalCash/1000000)
#      .labelType("percent")
#      .showLabels(true)
#      .valueFormat((d)-> accounting.formatNumber(d) + " Tr")
