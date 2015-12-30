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
    "click .customerToSales": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Meteor.call 'customerToOrder', customerId, (error, result) ->
          if error then console.log error else FlowRouter.go('order')

    "click .customerToReturn": (event, template) ->
      if customerId = Session.get('mySession').currentCustomer
        Meteor.call 'customerToReturn', customerId, (error, result) ->
          if error then console.log error else FlowRouter.go('orderReturn')
#
#    "click .customerExport": (event, template) ->
#      link = window.document.createElement('a')
#      link.setAttribute 'href', '/download/customer/' + Session.get("customerManagementCurrentCustomer")._id
#      link.click()

