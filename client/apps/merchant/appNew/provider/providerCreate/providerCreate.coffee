Wings.defineHyper 'providerCreate',
  created: ->
    console.log 'created providerCreate'
    self = this
    self.newProviderData = new ReactiveVar({})

  rendered: ->
    console.log 'render --------------- providerCreate'
#    @ui.$genderSwitch.bootstrapSwitch('onText', 'Nam')
#    @ui.$genderSwitch.bootstrapSwitch('offText', 'Nữ')

  helpers:
    codeDefault: ->
      merchantSummaries = Session.get('merchant')?.summaries ? {}
      lastProviderCode  = merchantSummaries.lastProviderCode ? 0
      listProviderCodes = merchantSummaries.listProviderCodes ? []
      Wings.Helper.checkAndGenerateCode(lastProviderCode, listProviderCodes, 'NCC')

  events:
    "click .cancelProvider": (event, template) ->
      FlowRouter.go('provider')

    "click .addProvider": (event, template) ->
      addNewProvider(event, template)

    "blur [name='providerName']": (event, template) ->
      checkProviderName(event, template)

#    "blur [name='providerPhone']": (event, template) ->
#      checkProviderPhone(event, template)

    "blur [name='providerCode']": (event, template) ->
      checkProviderCode(event, template)



#checkProviderPhone = (event, template, provider) ->
#  $providerPhone     = template.ui.$providerPhone
#  providerPhone      = $providerPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
#  listProviderPhones = Session.get('merchant')?.summaries?.listProviderPhones ? []
#  if providerPhone.length > 0
#    if _.indexOf(listProviderPhones, $providerPhone.val()) > -1
#      $providerPhone.addClass('error')
#      $providerPhone.notify('số điện thoại đã bị sử dụng', {position: "right"})
#      return false
#    else
#      provider.phone = providerPhone if provider
#  else
#    $providerPhone.removeClass('error')
#    $providerPhone.val('')


checkProviderName = (event, template, provider) ->
  $providerName = template.ui.$providerName
  providerName = $providerName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if providerName.length > 0
    $providerName.removeClass('error')
    provider.name = providerName if provider
  else
    $providerName.addClass('error')
    $providerName.notify('tên không được để trống', {position: "right"})
    return false

checkProviderCode = (event, template, provider) ->
  $providerCode     = template.ui.$providerCode
  providerCode      = $providerCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  listProviderCodes = Session.get('merchant')?.summaries?.listProviderCodes ? []

  if providerCode.length > 0
    if _.indexOf(listProviderCodes, providerCode) > -1
      $providerCode.addClass('error')
      $providerCode.notify('mã nhà cung cấp đã bị sử dụng', {position: "right"})
      return
    else
      provider.code = providerCode if provider
  else
    $providerCode.removeClass('error')
    $providerCode.val('')

addNewProvider = (event, template, provider = {}) ->
  if checkProviderName(event, template, provider)
    if checkProviderCode(event, template, provider)
      $providerPhone = template.ui.$providerPhone
      providerPhone  = $providerPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
      provider.phone = providerPhone if providerPhone

      $providerAddress = template.ui.$providerAddress
      providerAddress  = $providerAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
      provider.address = providerAddress if providerAddress

      $providerDescription = template.ui.$providerDescription
      providerDescription  = $providerDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
      provider.description = providerDescription if providerDescription

      newProviderId = Schema.providers.insert provider
      if Match.test(newProviderId, String)
        Provider.selectProvider(newProviderId)
        FlowRouter.go('provider')
        toastr["success"]("Tạo nhà cung cấp thành công.")
