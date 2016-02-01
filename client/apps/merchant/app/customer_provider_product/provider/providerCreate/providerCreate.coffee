Wings.defineHyper 'providerCreate',
  created: ->
  rendered: ->
    self = this
    integerOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", rightAlign: false, suffix: " VNĐ", integerDigits: 11}
    $providerDebit = self.ui.$providerDebit
    $providerDebit.inputmask "integer", integerOption

    decimalOption  = {autoGroup: true, groupSeparator:",", radixPoint: ".", rightAlign: false, suffix: " %/tháng", integerDigits:4}
    $providerInterestRate = self.ui.$providerInterestRate
    $providerInterestRate.inputmask "decimal", decimalOption

    self.ui.$providerName.select()


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

    "blur [name='providerCode']": (event, template) ->
      checkProviderCode(event, template)


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

      $providerRepresentative = template.ui.$providerRepresentative
      providerRepresentative  = $providerRepresentative.val().replace(/^\s*/, "").replace(/\s*$/, "")
      provider.representative = providerRepresentative if providerRepresentative


#      initialInterestRate = parseInt(template.ui.$providerInterestRate.inputmask('unmaskedvalue'))
#      provider.initialInterestRate = initialInterestRate if !isNaN(initialInterestRate)
#
#      initialStartDate  = template.datePicker.$providerDebitDate.datepicker().data().datepicker.dates.get()
#      provider.initialStartDate = initialStartDate if initialStartDate isnt undefined
#
#      initialAmount = parseInt(template.ui.$providerDebit.inputmask('unmaskedvalue'))
#      if !isNaN(initialAmount)
#        provider.initialAmount       = initialAmount
#        provider.initialInterestRate = 0 if !provider.initialInterestRate
#        provider.initialStartDate    = new Date() if !provider.initialStartDate

      newProviderId = Schema.providers.insert provider
      if Match.test(newProviderId, String)
        Provider.selectProvider(newProviderId)
        FlowRouter.go('provider')
        toastr["success"]("Tạo nhà cung cấp thành công.")
