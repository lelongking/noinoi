scope = logics.customerReturn

Wings.defineHyper 'orderReturnDetail',
  created: ->
  destroyed: ->

  helpers:
    orderReturnDetails: ->
      console.log Template.currentData()
      data = Template.currentData()
      orderReturn = data.orderReturn
      returnParent = data.returnParent

      return [] if !orderReturn or !returnParent

      orderReturnProductList = _.groupBy(orderReturn.details, (item, index) -> item.index = index; item.product)
      returnParentProductList = _.groupBy(returnParent.details, (item, index) -> item.index = index; item.product)


      for key, returnProductList of orderReturnProductList
        parentProductList = returnParentProductList[key]
        if parentProductList.length > 0
          availableReturnQuantity = 0
          for importDetail in parentProductList
            availableReturnQuantity += importDetail.basicQuantityAvailable

          returnQuantity  = 0
          for returnDetail in returnProductList
            returnQuantity += returnDetail.basicQuantity

          for returnDetail in returnProductList
            crossAvailable = availableReturnQuantity - returnQuantity

            returnDetail.crossAvailable = Math.ceil(Math.abs(crossAvailable/returnDetail.conversion))
            returnDetail.isValid = crossAvailable > 0
            returnDetail.invalid = crossAvailable < 0
            returnDetail.errorClass = if crossAvailable >= 0 then '' else 'errors'
      orderReturn.details

  events:
    "keyup": (event, template) ->
      Session.set("editingId") if event.which is 27

    "click .detail-row": ->
      Session.set("editingId", @_id)
      event.stopPropagation()

    "click .deleteReturnDetail": (event, template) ->
      currentCustomerReturn = Template.currentData().orderReturn
      currentCustomerReturn.removeReturnDetail(@_id)

    "keyup [name='returnDescription']": (event, template)->
      currentCustomerReturn = Template.currentData().orderReturn
      Helpers.deferredAction ->
        if Session.get('currentCustomerReturn')
          description = template.ui.$returnDescription.val()
          currentCustomerReturn.changeDescription(description)
      , "currentReturnUpdateDescription", 1000