lemon.defineApp Template.orderManagers,
  created: ->
    self = this
    self.autorun ()->

  rendered: ->
    $("[name=fromDate]").datepicker('setDate', Session.get('orderFilterStartDate'))
    $("[name=toDate]").datepicker('setDate', Session.get('orderFilterToDate'))

  events:
    "click .createSale": (event, template)-> FlowRouter.go('/sales')
    "click #filterBills": (event, template)->
      Session.set('orderFilterStartDate', $("[name=fromDate]").datepicker().data().datepicker.dates[0])
      Session.set('orderFilterToDate', $("[name=toDate]").datepicker().data().datepicker.dates[0])
    "click .thumbnails": (event, template) ->
#      Meteor.subscribe('saleDetails', @_id)
      Session.set('currentBillManagerSale', @)
      $(template.find '#salePreview').modal()