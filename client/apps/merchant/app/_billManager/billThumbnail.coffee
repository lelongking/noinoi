#scope = logics.billManager
#Enums = Apps.Merchant.Enums
#Wings.defineWidget 'billThumbnail',
#  helpers:
#    styles: -> if moment().subtract(7, 'days').startOf('day')._d > @accountingConfirmAt then 'pumpkin' else 'belize-hole'
#    customerAlias: -> Schema.customers.findOne(@buyer)?.name ? @contactName
#    countDay: -> moment(new Date()).diff(@accountingConfirmAt, 'days').toString()
#
#    isFinish: -> _.contains([Enums.getValue('OrderStatus', 'success'), Enums.getValue('OrderStatus', 'fail')], @orderStatus)
#    showStatus: ->
#      if @orderStatus is Enums.getValue('OrderStatus', 'exportConfirm') then 'Chờ Xác Nhận'
#      else if @orderStatus is Enums.getValue('OrderStatus', 'success') then 'Thành Công'
#      else if @orderStatus is Enums.getValue('OrderStatus', 'fail') then 'Thất Bại'
#
#  events:
#    "click .thumbnails": (event, template)->
#      Session.set("currentBillHistory", @)
#      FlowRouter.go 'billDetail'
#
#    "click .success-command": (event, template)->
#      if User.hasManagerRoles()
#        Meteor.call 'orderSuccessConfirm', @_id, (error, result) -> if error then console.log error
#      event.stopPropagation()
#
#    "click .fail-command": (event, template)->
#      if User.hasManagerRoles()
#        Meteor.call 'orderSuccessConfirm', @_id, false, (error, result) -> if error then console.log error
#      event.stopPropagation()
#
#    "click .cancel-command": (event, template)->
#      if User.hasManagerRoles()
#        Meteor.call 'orderUndoConfirm', @_id, (error, result) -> if error then console.log error
#      event.stopPropagation()
#
#    "click .finish-command": (event, template)->
#      if User.hasManagerRoles()
#        order = @
#        console.log @
#        if order.orderStatus is Enums.getValue('OrderStatus', 'fail')
#          Meteor.call 'orderImportConfirm', order._id, (error, result) ->
#            Meteor.call 'orderFinishConfirm', order._id, (error, result) -> if error then console.log error
#        else
#          Meteor.call 'orderFinishConfirm', order._id, (error, result) -> if error then console.log error
#      event.stopPropagation()