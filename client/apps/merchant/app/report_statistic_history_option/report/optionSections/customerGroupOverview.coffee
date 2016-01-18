
Enums = Apps.Merchant.Enums
Wings.defineApp 'customerGroupOverview',
  created: ->
    self = this
    self.autorun ()->

  rendered: ->
  destroyed: ->

  helpers:
    dataLists: ->
      dataLists =
        details : []
        overview:
          count     : 0
          totalCash : 0
          paidCash  : 0

      currentDynamic = Session.get("reportOptionsCurrentDynamics")
      return dataLists if !currentDynamic


      dataLists.details = Schema.customerGroups.find({
        merchant    : merchantId ? Merchant.getId()
      }, {sort:{nameSearch: 1}}).map(
        (item) ->
          dataLists.overview.count     += 1
          dataLists.overview.totalCash += item.totalCash
#          dataLists.overview.paidCash  += item.paidCash
          item.count                    = dataLists.overview.count
          item
      )
      dataLists




#  events:
#    "change": (event, template) ->
#      dateRange = Session.get('reportOptionsDateRange')
#      if event.target.name is 'startDate'
#        getStartDate = template.datePicker.$startDate.data('datepicker').dates[0]
#        if moment(dateRange.startDate).format('DD/MM/YYYY') isnt moment(getStartDate).format('DD/MM/YYYY')
#          dateRange.startDate = moment(getStartDate).startOf('day')._d
#          Session.set('reportOptionsDateRange', dateRange)
#
#      else if event.target.name is 'endDate'
#        getEndDate = template.datePicker.$endDate.data('datepicker').dates[0]
#        if moment(dateRange.endDate).format('DD/MM/YYYY') isnt moment(getEndDate).format('DD/MM/YYYY')
#          dateRange.endDate = moment(getEndDate).endOf('day')._d
#          Session.set('reportOptionsDateRange', dateRange)