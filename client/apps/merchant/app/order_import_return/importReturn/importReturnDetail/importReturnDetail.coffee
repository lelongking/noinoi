scope = logics.providerReturn

Wings.defineHyper 'importReturnDetail',
  created: ->
  destroyed: ->

  helpers:
    importReturnDetails: ->
      data = Template.currentData()
      importReturn = data.importReturn
      returnParent = data.returnParent

      return [] if !importReturn or !returnParent

      importReturnProductList = _.groupBy(importReturn.details, (item, index) -> item.index = index; item.product)
      returnParentProductList = _.groupBy(returnParent.details, (item, index) -> item.index = index; item.product)


      for key, returnProductList of importReturnProductList
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
      importReturn.details

  events:
    "keyup": (event, template) ->
      if event.which is 27
        Session.set("editingId")

    "click .detail-row": ->
      Session.set("editingId", @_id)
      event.stopPropagation()

    "click .deleteReturnDetail": (event, template) ->
      importReturn = Template.currentData().importReturn
      importReturn.removeReturnDetail(@_id)

    "keyup [name='returnDescription']": (event, template)->
      importReturn = Template.currentData().importReturn
      Helpers.deferredAction ->
        if Session.get('currentProviderReturn')
          description = template.ui.$returnDescription.val()
          importReturn.changeDescription(description)
      , "currentReturnUpdateDescription", 1000