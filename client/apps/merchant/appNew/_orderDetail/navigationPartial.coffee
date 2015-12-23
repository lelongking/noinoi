Wings.defineApp 'orderDetailNavigationPartial',
  events:
    "click .clearBillHistory": (event, template) ->
      Session.set("currentBillHistory")
      Session.set("editingId")
      FlowRouter.go 'billManager'