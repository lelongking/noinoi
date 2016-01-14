scope = logics.warehouseOptions

Wings.defineHyper 'warehouseInfoOptions',
  created: ->
    self = this
    self.showSyncCommand = new ReactiveVar(false)

  helpers:
    warehouseProfile: -> Session.get('merchant')?.branches[0]
    showSyncCommand: -> Template.instance().showSyncCommand.get()


  events:
    "click .rollBackWarehouseProfileEdit": (event, template) ->
      rollBackWarehouseProfileData(event, template)

    "input .warehouseProfileOption": (event, template) ->
      checkUpdateWarehouseProfileEdit(event, template)

    "keyup .warehouseProfileOption": (event, template) ->
      if event.which is 13
        syncWarehouseProfileData(event, template)
      else if event.which is 27
        rollBackWarehouseProfileData(event, template)

    "click .syncWarehouseProfileEdit": (event, template) ->
      syncWarehouseProfileData(event, template)




#-----------------------------------------------------------------------------------------------------------------------
checkUpdateWarehouseProfileEdit = (event, template) ->
  if warehouseData = Session.get('merchant')?.branches[0]
    checkWarehouseProfileData =
      template.ui.$warehouseName.val() isnt (warehouseData.name ? '') or
        template.ui.$warehousePhone.val() isnt (warehouseData.phone ? '') or
#        template.ui.$warehouseDescription.val() isnt (warehouseData.description ? '') or
        template.ui.$warehouseAddress.val() isnt (warehouseData.address ? '')

    Template.instance().showSyncCommand.set(checkWarehouseProfileData)

syncWarehouseProfileData = (event, template)->
  if Template.instance().showSyncCommand.get()
    warehouseData        = Session.get('merchant')?.branches[0]
    warehouseName        = template.ui.$warehouseName.val()
    warehousePhone       = template.ui.$warehousePhone.val()
#    warehouseDescription = template.ui.$warehouseDescription.val()
    warehouseAddress     = template.ui.$warehouseAddress.val()


    option = $set:{}
    option.$set['branches.0.name']        = warehouseName if warehouseName isnt (warehouseData.name ? '')
    option.$set['branches.0.address']     = warehouseAddress if warehouseAddress isnt (warehouseData.address ? '')
#    option.$set['branches.0.description'] = warehouseDescription if warehouseDescription isnt (warehouseData.description ? '')
    option.$set['branches.0.phone']       = warehousePhone if warehousePhone isnt (warehouseData.phone ? '')

    if !_.isEmpty(option.$set)
      Schema.merchants.update(warehouseData.merchantId, option)
      Template.instance().showSyncCommand.set(false)

rollBackWarehouseProfileData = (event, template)->
  if Template.instance().showSyncCommand.get()
    warehouseData = Session.get('merchant')?.branches[0]
    template.ui.$warehouseName.val(warehouseData.name)
    template.ui.$warehousePhone.val(warehouseData.phone)
#    template.ui.$warehouseDescription.val(warehouseData.description)
    template.ui.$warehouseAddress.val(warehouseData.address)
    Template.instance().showSyncCommand.set(false)