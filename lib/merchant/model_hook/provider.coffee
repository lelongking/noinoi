providerCalculateTotalCash = (provider) ->
  importCash               = (provider.importAmount ? 0) + (provider.returnPaidAmount ? 0) - (provider.returnAmount ? 0)
  provider.debitCash       = importCash + (provider.loanAmount ? 0)
  provider.interestCash    = (provider.interestAmount ? 0)
  provider.paidCash        = (provider.paidAmount ? 0)
  provider.totalDebitCash  = (provider.initialAmount ? 0) + provider.debitCash
  provider.totalCash       = provider.totalDebitCash + provider.interestCash - provider.paidCash
  provider


  

#----------Before-Insert------------------------------------------------------------------------------------------------
generateProviderCode = (user, provider, summaries)->
  lastProviderCode  = summaries.lastProviderCode ? 0
  listProviderCodes = summaries.listProviderCodes ? []

  provider.code = (provider.code ? '').replace(/^\s*/, "").replace(/\s*$/, "")
  if provider.code.length is 0 or _.indexOf(listProviderCodes, provider.code) > -1
    provider.code = Wings.Helper.checkAndGenerateCode(lastProviderCode, listProviderCodes, 'NCC')
    
generateProviderInitCash = (provider)->
  provider.debtRequiredCash = 0
  provider.paidRequiredCash = 0
  provider.debtBeginCash    = 0
  provider.paidBeginCash    = 0
  provider.debtIncurredCash = 0
  provider.paidIncurredCash = 0
  provider.debtSaleCash     = 0
  provider.paidSaleCash     = 0
  provider.returnSaleCash   = 0

generateProviderInit = (user, provider, splitName)->
  provider.merchant     = user.profile.merchant
  provider.creator      = user._id
  provider.allowDelete  = true

  provider.nameSearch   = Helpers.Searchify(provider.name)
  provider.firstName    = splitName.firstName
  provider.lastName     = splitName.lastName

Schema.providers.before.insert (userId, provider)->
  user      = Meteor.users.findOne(userId)
  splitName = Helpers.GetFirstNameOrLastName(provider.name)
  merchant  = Schema.merchants.findOne({_id: user.profile.merchant})

  generateProviderCode(user, provider, merchant.summaries)
  generateProviderInit(user, provider, splitName)
  generateProviderInitCash(provider)








#----------After-Insert-------------------------------------------------------------------------------------------------
addProviderCodeInMerchantSummary = (userId, provider) ->
  if provider.code
    Schema.merchants.direct.update provider.merchant, $addToSet: {'summaries.listProviderCodes': provider.code}

Schema.providers.after.insert (userId, provider)->
  addProviderCodeInMerchantSummary(userId, provider)










#----------Before-Update------------------------------------------------------------------------------------------------
updateIsNameChangedOfProvider = (userId, provider, fieldNames, modifier, options) ->
  if _.contains(fieldNames, "name")
    if provider.name isnt modifier.$set.name
      modifier.$set.nameSearch  = Helpers.Searchify(modifier.$set.name)

      splitName = Helpers.GetFirstNameOrLastName(modifier.$set.name)
      if provider.firstName isnt splitName.firstName
        modifier.$set.firstName = splitName.firstName

      if provider.lastName isnt splitName.lastName
        if Meteor.isServer
          if !modifier.$unset or modifier.$unset.lastName
            modifier.$set.lastName = splitName.lastName
        else
          modifier.$set.lastName  = splitName.lastName

Schema.providers.before.update (userId, provider, fieldNames, modifier, options) ->
  updateIsNameChangedOfProvider(userId, provider, fieldNames, modifier, options)













#----------After-Update-------------------------------------------------------------------------------------------------
updateProviderCodeInMerchantSummary = (userId, oldProvider, newProvider) ->
  if oldProvider.code isnt newProvider.code
    if oldProvider.code
      Schema.merchants.direct.update oldProvider.merchant, $pull: {'summaries.listProviderCodes': oldProvider.code}
    if newProvider.code
      Schema.merchants.direct.update oldProvider.merchant, $addToSet: {'summaries.listProviderCodes': newProvider.code}

Schema.providers.after.update (userId, newProvider, fieldNames, modifier, options) ->
  oldProvider = @previous
  updateProviderCodeInMerchantSummary(userId, oldProvider, newProvider)




#----------After-Remove-------------------------------------------------------------------------------------------------
removeImportAndReturnAndTransaction = (userId, provider)->
  Schema.imports.direct.remove({provider: provider._id})
  Schema.returns.direct.remove({owner: provider._id})
  Schema.transactions.direct.remove({owner: customer._id})


removeProviderCodeInMerchantSummary = (userId, provider)->
  if provider.code
    Schema.merchants.direct.update provider.merchant, $pull: {'summaries.listProviderCodes': provider.code}

Schema.providers.after.remove (userId, provider)->
  if Meteor.isServer
    provider = providerCalculateTotalCash(provider)

    removeImportAndReturnAndTransaction(userId, provider)
    removeProviderCodeInMerchantSummary(userId, provider)
