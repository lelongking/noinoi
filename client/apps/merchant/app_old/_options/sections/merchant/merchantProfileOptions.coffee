scope = logics.merchantOptions

Wings.defineHyper 'merchantInfoOptions',
  created: ->
    self = this
    self.showSyncCommand = new ReactiveVar(false)

  helpers:
    merchantProfile: -> Session.get('merchant')
    showSyncCommand: -> Template.instance().showSyncCommand.get()


  events:
    "click .rollBackMerchantProfileEdit": (event, template) ->
      rollBackMerchantProfileData(event, template)

    "input .merchantProfileOption": (event, template) ->
      checkUpdateMerchantProfileEdit(event, template)

    "keyup .merchantProfileOption": (event, template) ->
      if event.which is 13
        syncMerchantProfileData(event, template)
      else if event.which is 27
        rollBackMerchantProfileData(event, template)

    "click .syncMerchantProfileEdit": (event, template) ->
      syncMerchantProfileData(event, template)




#-----------------------------------------------------------------------------------------------------------------------
checkUpdateMerchantProfileEdit = (event, template) ->
  if merchantData = Session.get('merchant')
    checkMerchantProfileData =
      template.ui.$merchantName.val() isnt (merchantData.name ? '') or
        template.ui.$merchantPhone.val() isnt (merchantData.phone ? '') or
        template.ui.$merchantEmail.val() isnt (merchantData.email ? '') or
        template.ui.$merchantAddress.val() isnt (merchantData.address ? '')

    Template.instance().showSyncCommand.set(checkMerchantProfileData)

syncMerchantProfileData = (event, template)->
  if Template.instance().showSyncCommand.get()
    merchantData = Session.get('merchant')
    merchantName    = template.ui.$merchantName.val()
    merchantPhone   = template.ui.$merchantPhone.val()
    merchantEmail   = template.ui.$merchantEmail.val()
    merchantAddress = template.ui.$merchantAddress.val()


    option = $set:{}
    option.$set.name    = merchantName if merchantName isnt (merchantData.name ? '')
    option.$set.address = merchantAddress if merchantAddress isnt (merchantData.address ? '')
    option.$set.email   = merchantEmail if merchantEmail isnt (merchantData.address ? '')
    option.$set.phone   = merchantPhone if merchantPhone isnt (merchantData.address ? '')

    if !_.isEmpty(option.$set)
      Schema.merchants.update(merchantData._id, option)
      Template.instance().showSyncCommand.set(false)

rollBackMerchantProfileData = (event, template)->
  if Template.instance().showSyncCommand.get()
    merchantData = Session.get('merchant')
    template.ui.$merchantName.val(merchantData.name)
    template.ui.$merchantPhone.val(merchantData.phone)
    template.ui.$merchantEmail.val(merchantData.email)
    template.ui.$merchantAddress.val(merchantData.address)
    Template.instance().showSyncCommand.set(false)