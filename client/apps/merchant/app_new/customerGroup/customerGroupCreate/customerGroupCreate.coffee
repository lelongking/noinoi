Wings.defineHyper 'customerGroupCreate',
  created: ->
    self = this

  rendered: ->

#  helpers:
#    codeDefault: ->

  events:
    "click .cancelProductGroup": (event, template) ->
      FlowRouter.go('customerGroup')

    "click .addProductGroup": (event, template) ->
      addNewProductGroup(event, template)

    "blur [name='customerGroupName']": (event, template) ->
      checkProductGroupName(event, template)

    "blur [name='customerGroupDescription']": (event, template) ->
      checkProductGroupDescription(event, template)


checkProductGroupName = (event, template, customerGroup) ->
  $customerGroupName = template.ui.$customerGroupName
  customerGroupName = $customerGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if customerGroupName.length > 0
    $customerGroupName.removeClass('error')
    customerGroup.name = customerGroupName if customerGroup
    return true
  else
    $customerGroupName.addClass('error')
    $customerGroupName.notify('tên không được để trống', {position: "right"})
    return false

checkProductGroupDescription = (event, template, customerGroup) ->
  $customerGroupDescription = template.ui.$customerGroupDescription
  customerGroupDescription  = $customerGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if customerGroupDescription.length > 0
    customerGroup.description = customerGroupDescription if customerGroup
  return true

addNewProductGroup = (event, template, customerGroup = {}) ->
  if checkProductGroupName(event, template, customerGroup)
    if checkProductGroupDescription(event, template, customerGroup)
      console.log customerGroup
      newProductGroupId = Schema.customerGroups.insert customerGroup
      if Match.test(newProductGroupId, String)
        ProductGroup.setSessionProductGroup(newProductGroupId)
        FlowRouter.go('customerGroup')
        toastr["success"]("Tạo nhóm khách hàng thành công.")