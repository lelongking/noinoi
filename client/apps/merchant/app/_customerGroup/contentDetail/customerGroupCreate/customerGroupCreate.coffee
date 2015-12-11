Wings.defineHyper 'customerGroupCreate',
  created: ->
    self = this

  rendered: ->

#  helpers:
#    codeDefault: ->

  events:
    "click .cancelCustomerGroup": (event, template) ->
      FlowRouter.go('customerGroup')

    "click .addCustomerGroup": (event, template) ->
      addNewCustomerGroup(event, template)

    "blur [name='customerGroupName']": (event, template) ->
      checkCustomerGroupName(event, template)

    "blur [name='customerGroupDescription']": (event, template) ->
      checkCustomerGroupDescription(event, template)


checkCustomerGroupName = (event, template, customerGroup) ->
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

checkCustomerGroupDescription = (event, template, customerGroup) ->
  $customerGroupDescription = template.ui.$customerGroupDescription
  customerGroupDescription  = $customerGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
  if customerGroupDescription.length > 0
    customerGroup.description = customerGroupDescription if customerGroup
  return true

addNewCustomerGroup = (event, template, customerGroup = {}) ->
  if checkCustomerGroupName(event, template, customerGroup)
    if checkCustomerGroupDescription(event, template, customerGroup)
      console.log customerGroup
      newCustomerGroupId = Schema.customerGroups.insert customerGroup
      if Match.test(newCustomerGroupId, String)
        CustomerGroup.setSessionCustomerGroup(newCustomerGroupId)
        FlowRouter.go('customerGroup')
        toastr["success"]("Tạo nhóm khách hàng thành công.")