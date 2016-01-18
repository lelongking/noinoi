activityOption =  [
  display: "tổng quan"
  icon: "icon-laptop"
  template: 'activityOverview'
,
  display: "nhập kho"
  icon: "icon-inbox-1"
  template: 'importOverview'
,
  display: "trả nhập"
  icon: "icon-reply-3"
  template: 'importReturnOverview'
,
  display: "bán hàng"
  icon: "icon-basket"
  template: 'saleOverview'
,
  display: "trả bán"
  icon: "icon-reply-all-1"
  template: 'saleReturnOverview'
]

transactionOption =  [
  display: "khách hàng"
  icon: "icon-user-7"
  template: "customerOverview"
,
  display: "nhóm khách hàng"
  icon: "icon-group"
  template: "customerGroupOverview"
,
  display: "nhà cung cấp"
  icon: "icon-users"
  template: "providerOverview"
]

reportOption = [
  group: 'NHẬP XUẤT'
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


  events:
    "click .caption.inner": (event, template) ->
      Session.set("reportSectionSearchProduct", false)
      Session.get('reportSectionProductSearchText', '')
      Session.set("reportOptionsCurrentDynamics", @)


#
#    "keyup input[name='searchProductFilter']": (event, template) ->
#      Helpers.deferredAction ->
#        searchFilter = $("input[name='searchProductFilter']").val()
#        searchFilter = searchFilter.replace(/(?:(?:^|\n)\s+|\s+(?:$|\n))/g,"").replace(/\s+/g," ")
#        Session.set("reportSectionProductSearchText", searchFilter)
#        Session.set("reportSectionSearchProduct", false) if searchFilter.length is 0
#      , "reportSectionProductSearchText"
#      , 200
#
#
#    "click .detail-row": (event, template) ->
#      currentDynamic = Session.get("reportOptionsCurrentDynamics")
#      if currentDynamic.template is reportOption[0].optionChild[3].template
#        Session.set("reportSummaryProductLowNormsEditId", @_id)
#      else
#        Session.set("reportSummaryProductLowNormsEditId", '')
#
#
#    "click .searchProduct": (event, template) ->
#      isSearch = Session.get("reportSectionSearchProduct")
#      Session.set("reportSectionSearchProduct", !isSearch)
#      Session.set("reportSectionProductSearchText",'')



