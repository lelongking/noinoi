setTime = -> Session.set('realtime-now', new Date())

Wings.defineHyper 'importProductDetail',
  helpers:
    provider: -> Session.get('currentProvider')
    billNo: -> Helpers.orderCodeCreate(Session.get('currentProvider')?.billNo ? '0000')
    dueDate: -> moment().add(Session.get('currentImport').dueDay, 'days').endOf('day').format("DD/MM/YYYY") if Session.get('currentImport')

    oldDebt: -> if provider = Session.get('currentProvider') then provider.totalCash else 0
    finalDebt: ->
      if currentImport = Session.get("currentImport")
        if provider = Session.get('currentProvider')
          provider.totalCash + currentImport.finalPrice - currentImport.depositCash
        else
          Session.get("currentImport").finalPrice - Session.get("currentImport").depositCash
      else 0

  created  : ->
    @timeInterval = Meteor.setInterval(setTime, 1000)

  destroyed: ->
    Meteor.clearInterval(@timeInterval)

  events:
    "click .deleteImportDetail": (event, template) ->
      if currentImport = Template.currentData()
        currentImport.removeImportDetail(@_id)

    "click .detail-row": (event, template) ->
      Session.set("editingId", @_id)
      event.stopPropagation()

    "keyup": (event, template) ->
      if event.which is 27
        Session.set("editingId")

    "keyup [name='importDescription']": (event, template)->
      currentImport = Template.currentData()
      Helpers.deferredAction ->
        if currentImport
          description = template.ui.$importDescription.val()
          currentImport.changeField('description', description)
      , "currentImportUpdateDescription", 1000
