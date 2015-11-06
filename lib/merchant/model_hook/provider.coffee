#----------Before-Insert---------------------------------------------------------------------------------------------
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


#----------After-Insert------------------------------------------------------------------------------------------------
addProviderInProviderGroup = (userId, provider) ->
  console.log provider
  if provider.providerOfGroup
    providerGroupUpdate =
      $pull:
        providerLists: provider._id
      $inc:
        debtRequiredCash: provider.debtRequiredCash
        paidRequiredCash: provider.paidRequiredCash
        debtBeginCash   : provider.debtBeginCash
        paidBeginCash   : provider.paidBeginCash
        debtIncurredCash: provider.debtIncurredCash
        paidIncurredCash: provider.paidIncurredCash
        debtSaleCash    : provider.debtSaleCash
        paidSaleCash    : provider.paidSaleCash
        returnSaleCash  : provider.returnSaleCash
    Schema.providerGroups.direct.update(provider.providerOfGroup, providerGroupUpdate)

#----------Before-Update---------------------------------------------------------------------------------------------
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

#----------After-Update-------------------------------------------------------------------------------------------------
updateCashOfProviderGroup = (userId, oldProvider, newProvider, fieldNames, modifier, options) ->
  updateOption = $inc:{}

  fieldLists = [
      'debtRequiredCash'
      'paidRequiredCash'
      'debtBeginCash'
      'paidBeginCash'
      'debtIncurredCash'
      'paidIncurredCash'
      'debtSaleCash'
      'paidSaleCash'
      'returnSaleCash'
    ]

  for fieldName in fieldLists
    if oldProvider[fieldName] isnt newProvider[fieldName]
      updateOption.$inc[fieldName] = newProvider[fieldName] - oldProvider[fieldName]

  if !_.isEmpty(updateOption.$inc)
    Schema.providerGroups.direct.update oldProvider.providerOfGroup, updateOption

updateProviderGroup = (userId, oldProvider, newProvider, fieldNames, modifier, options) ->
  updateOldProviderGroup =
    $pull:
      providerLists: oldProvider.providerOfGroup
    $inc:
      debtRequiredCash: -oldProvider.debtRequiredCash
      paidRequiredCash: -oldProvider.paidRequiredCash
      debtBeginCash   : -oldProvider.debtBeginCash
      paidBeginCash   : -oldProvider.paidBeginCash
      debtIncurredCash: -oldProvider.debtIncurredCash
      paidIncurredCash: -oldProvider.paidIncurredCash
      debtSaleCash    : -oldProvider.debtSaleCash
      paidSaleCash    : -oldProvider.paidSaleCash
      returnSaleCash  : -oldProvider.returnSaleCash
  Schema.providerGroups.direct.update oldProvider.providerOfGroup, updateOldProviderGroup


  updateNewProviderGroup =
    $addToSet:
      providerLists: newProvider.providerOfGroup
    $inc:
      debtRequiredCash: newProvider.debtRequiredCash
      paidRequiredCash: newProvider.paidRequiredCash
      debtBeginCash   : newProvider.debtBeginCash
      paidBeginCash   : newProvider.paidBeginCash
      debtIncurredCash: newProvider.debtIncurredCash
      paidIncurredCash: newProvider.paidIncurredCash
      debtSaleCash    : newProvider.debtSaleCash
      paidSaleCash    : newProvider.paidSaleCash
      returnSaleCash  : newProvider.returnSaleCash
  Schema.providerGroups.direct.update newProvider.providerOfGroup, updateNewProviderGroup

#----------Before-Remove-----------------------------------------------------------------------------------------------
#----------After-Remove-------------------------------------------------------------------------------------------------



#-----------------------------------------------------------------------------------------------------------------------
Schema.providers.before.insert (userId, provider)->
  user = Meteor.users.findOne(userId)
  splitName = Helpers.GetFirstNameOrLastName(provider.name)
  generateProviderInit(user, provider, splitName)
  generateProviderInitCash(provider)

#Schema.providers.after.insert (userId, provider) ->

#-----------------------------------------------------------------------------------------------------------------------
Schema.providers.before.update (userId, provider, fieldNames, modifier, options) ->
  updateIsNameChangedOfProvider(userId, provider, fieldNames, modifier, options)

#Schema.providers.after.update (userId, newProvider, fieldNames, modifier, options) ->
#  oldProvider = @previous

##-----------------------------------------------------------------------------------------------------------------------
#Schema.providers.before.remove (userId, provider) ->
#
#Schema.providers.after.remove (userId, doc)->