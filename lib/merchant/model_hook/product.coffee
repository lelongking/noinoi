#----------Before-Insert---------------------------------------------------------------------------------------------
generateProductCode = (user, product, summaries)->
  lastProductCode  = summaries.lastProductCode ? 0
  listProductCodes = summaries.listProductCodes ? []

  product.code = (product.code ? '').replace(/^\s*/, "").replace(/\s*$/, "")
  if product.code.length is 0 or _.indexOf(listProductCodes, product.code) > -1
    product.code = Wings.Helper.checkAndGenerateCode(lastProductCode, listProductCodes, 'SP')


generateProductInit = (user, product)->
  product.nameSearch   = Helpers.Searchify(product.name)
  product.merchant     = user.profile.merchant
  product.creator      = user._id
  product.allowDelete  = true


setProductGroupDefault = (user, product)->
  if !product.productOfGroup
    merchantId = user.profile.merchant
    groupBasic = Schema.productGroups.findOne({merchant: merchantId, isBase: true})
    product.productOfGroup = groupBasic._id if groupBasic



Schema.products.before.insert (userId, product)->
  user      = Meteor.users.findOne({_id:userId})
  merchant  = Schema.merchants.findOne({_id: user.profile.merchant})

  generateProductInit(user, product)
  generateProductCode(user, product, merchant.summaries)
  setProductGroupDefault(user, product)



#----------After-Insert------------------------------------------------------------------------------------------------
addProductInProductGroup = (userId, product) ->
  if product.productOfGroup
    productGroupUpdate =
      $addToSet:
        products: product._id
    Schema.productGroups.direct.update(product.productOfGroup, productGroupUpdate)

addProductCodeInMerchantSummary = (userId, product) ->
  if product.code
    Schema.merchants.direct.update product.merchant, $addToSet: {'summaries.listProductCodes': product.code}


Schema.products.after.insert (userId, product) ->
  if Schema.products.findOne({_id: product._id})
    addProductInProductGroup(userId, product)
    addProductCodeInMerchantSummary(userId, product)
    PriceBook.addProduct(product._id)



##----------Before-Update---------------------------------------------------------------------------------------------
updateIsNameChangedOfProduct = (userId, product, fieldNames, modifier, options) ->
  if _.contains(fieldNames, "name")
    if product.name isnt modifier.$set.name
      modifier.$set.nameSearch  = Helpers.Searchify(modifier.$set.name)


Schema.products.before.update (userId, product, fieldNames, modifier, options) ->
  updateIsNameChangedOfProduct(userId, product, fieldNames, modifier, options)


#----------After-Update-------------------------------------------------------------------------------------------------
updateCashOfProductGroup = (userId, oldProduct, newProduct, fieldNames, modifier, options) ->
#  updateOption = $inc:{}
#
#  fieldLists = [
#      'debtRequiredCash'
#      'paidRequiredCash'
#      'debtBeginCash'
#      'paidBeginCash'
#      'debtIncurredCash'
#      'paidIncurredCash'
#      'debtSaleCash'
#      'paidSaleCash'
#      'returnSaleCash'
#    ]
#
#  for fieldName in fieldLists
#    if oldProduct[fieldName] isnt newProduct[fieldName]
#      updateOption.$inc[fieldName] = newProduct[fieldName] - oldProduct[fieldName]
#
#  if !_.isEmpty(updateOption.$inc)
#    Schema.productGroups.direct.update oldProduct.productOfGroup, updateOption

updateProductGroup = (userId, oldProduct, newProduct, fieldNames, modifier, options) ->
  updateOldProductGroup =
    $pull:
      products: oldProduct.productOfGroup
#    $inc:
#      debtRequiredCash: -oldProduct.debtRequiredCash
#      paidRequiredCash: -oldProduct.paidRequiredCash
#      debtBeginCash   : -oldProduct.debtBeginCash
#      paidBeginCash   : -oldProduct.paidBeginCash
#      debtIncurredCash: -oldProduct.debtIncurredCash
#      paidIncurredCash: -oldProduct.paidIncurredCash
#      debtSaleCash    : -oldProduct.debtSaleCash
#      paidSaleCash    : -oldProduct.paidSaleCash
#      returnSaleCash  : -oldProduct.returnSaleCash
  Schema.productGroups.direct.update oldProduct.productOfGroup, updateOldProductGroup


  updateNewProductGroup =
    $addToSet:
      products: newProduct.productOfGroup
#    $inc:
#      debtRequiredCash: newProduct.debtRequiredCash
#      paidRequiredCash: newProduct.paidRequiredCash
#      debtBeginCash   : newProduct.debtBeginCash
#      paidBeginCash   : newProduct.paidBeginCash
#      debtIncurredCash: newProduct.debtIncurredCash
#      paidIncurredCash: newProduct.paidIncurredCash
#      debtSaleCash    : newProduct.debtSaleCash
#      paidSaleCash    : newProduct.paidSaleCash
#      returnSaleCash  : newProduct.returnSaleCash
  Schema.productGroups.direct.update newProduct.productOfGroup, updateNewProductGroup

Schema.products.after.update (userId, newProduct, fieldNames, modifier, options) ->
  oldProduct = @previous
  isChangeProductGroup = oldProduct.productOfGroup isnt newProduct.productOfGroup

#  if isChangeProductGroup
#    updateCashOfProductGroup(userId, oldProduct, newProduct, fieldNames, modifier, options)
#  else
#    updateProductGroup(userId, oldProduct, newProduct, fieldNames, modifier, options)




#----------Before-Remove-----------------------------------------------------------------------------------------------
Schema.products.before.remove (userId, product) ->



#----------After-Remove-------------------------------------------------------------------------------------------------
removeCashOfProductCash = (userId, product)->
  if product.productOfGroup
    productGroupUpdate =
      $pull:
        products: product._id
#      $inc:
#        debtRequiredCash: -product.debtRequiredCash
#        paidRequiredCash: -product.paidRequiredCash
#        debtBeginCash   : -product.debtBeginCash
#        paidBeginCash   : -product.paidBeginCash
#        debtIncurredCash: -product.debtIncurredCash
#        paidIncurredCash: -product.paidIncurredCash
#        debtSaleCash    : -product.debtSaleCash
#        paidSaleCash    : -product.paidSaleCash
#        returnSaleCash  : -product.returnSaleCash
    Schema.productGroups.direct.update(product.productOfGroup, productGroupUpdate)

Schema.products.after.remove (userId, doc)->
  removeCashOfProductCash(userId, doc)
