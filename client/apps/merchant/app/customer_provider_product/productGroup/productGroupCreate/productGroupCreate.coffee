Wings.defineHyper 'productGroupCreate',
  created: ->


  rendered: ->
    self = this
    self.ui.$productGroupName.select()

#  helpers:
#    codeDefault: ->

  events:
    "click .cancelProductGroup": (event, template) ->
      FlowRouter.go('productGroup')

    "click .addProductGroup": (event, template) ->
      addNewProductGroup(event, template)

    "blur [name='productGroupName']": (event, template) ->
      checkProductGroupName(event, template)

    "blur [name='productGroupDescription']": (event, template) ->
      checkProductGroupDescription(event, template)


checkProductGroupName = (event, template, productGroup) ->
  $productGroupName = template.ui.$productGroupName
  productGroupName = $productGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if productGroupName.length > 0
    $productGroupName.removeClass('error')
    productGroup.name = productGroupName if productGroup
    return true
  else
    $productGroupName.addClass('error')
    $productGroupName.notify('tên không được để trống', {position: "right"})
    return false

checkProductGroupDescription = (event, template, productGroup) ->
  $productGroupDescription = template.ui.$productGroupDescription
  productGroupDescription  = $productGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if productGroupDescription.length > 0
    productGroup.description = productGroupDescription if productGroup
  return true

addNewProductGroup = (event, template, productGroup = {}) ->
  if checkProductGroupName(event, template, productGroup)
    if checkProductGroupDescription(event, template, productGroup)
      console.log productGroup
      newProductGroupId = Schema.productGroups.insert productGroup
      if Match.test(newProductGroupId, String)
        ProductGroup.setSessionProductGroup(newProductGroupId)
        FlowRouter.go('productGroup')
        toastr["success"]("Tạo nhóm sản phẩm thành công.")