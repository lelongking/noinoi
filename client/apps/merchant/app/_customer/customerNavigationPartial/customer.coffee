Enums = Apps.Merchant.Enums
Wings.defineApp 'customerManagementNavigationPartial',
  helpers:
    navigates: [
      {
        defaultClass: 'inav teleport animated'
        class: 'customerToSales'
        icon: 'icon-basket'
        animate: 'fadeInDown'
        color: 'blue'
        name: 'bán hàng'
      }
    ,
      {

      }
    ,
      {

      }
    ,
      {

      }

    ]
  events:
    "click .customerPaid": (event, template) ->
      oldDebt = Session.get("customerManagementOldDebt")
      if oldDebt is false
        Session.set("customerManagementOldDebt")
      else
        Session.set("customerManagementOldDebt", false)

    "click .customerToSales": (event, template) ->
      if customer = Session.get("customerManagementCurrentCustomer")
        Meteor.call 'customerToOrder', customer._id, (error, result) -> if error then console.log error else Router.go('/sales')

    "click .customerExport": (event, template) ->
      link = window.document.createElement('a')
      link.setAttribute 'href', '/download/customer/' + Session.get("customerManagementCurrentCustomer")._id
      link.click()

