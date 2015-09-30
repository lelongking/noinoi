Enums = Apps.Merchant.Enums
logics.customerGroup = {} unless logics.customerGroup
scope = logics.customerGroup

scope.resetSearchFilter = (template) ->
  template.ui.$searchFilter.val('')
  Session.set("customerGroupSearchFilter", "")
  Session.set("customerGroupCreationMode", false)

scope.checkAllowUpdateOverviewCustomerGroup = (template) ->
  Session.set "customerGroupShowEditCommand",
    template.ui.$customerGroupName.val() isnt Session.get("currentCustomerGroup").name or
      template.ui.$customerGroupDescription.val() isnt (Session.get("currentCustomerGroup").description ? '')


scope.searchFindPreviousCustomerGroup = (customerSearch) ->
  if previousRow = scope.customerGroupLists.getPreviousBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': previousRow._id}})


scope.searchFindNextCustomerGroup = (customerSearch) ->
  if nextRow = scope.customerGroupLists.getNextBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': nextRow._id}})


#----------------------------------------------------------------------------------------------------------
formatCustomerSearch = (item) -> "#{item.name}" if item
scope.customerGroupSelects =
  query: (query) -> query.callback
    results: Schema.customerGroups.find({$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not:scope.currentCustomerGroup._id }}]}).fetch()
    text: 'name'
  initSelection: (element, callback) -> callback 'skyReset'
  formatSelection: formatCustomerSearch
  formatResult: formatCustomerSearch
  id: '_id'
  placeholder: 'CHỌN NHÓM'
  changeAction: (e) -> scope.currentCustomerGroup.changeCustomerTo(e.added._id) if User.hasManagerRoles()
  reactiveValueGetter: -> 'skyReset'


scope.createNewCustomerGroup = (template) ->
  name = Session.get("customerGroupSearchFilter")
  if name?.length > 0 and Session.get("customerGroupCreationMode")
    if CustomerGroup.nameIsExisted(name, Session.get("myProfile").merchant)
      template.ui.$searchFilter.notify("Nhóm khách hàng đã tồn tại.", {position: "bottom"})
    else
      scope.resetSearchFilter(template) if CustomerGroup.insert(name)


scope.editCustomerGroup = (template) ->
  group = Session.get("currentCustomerGroup")
  if group and Session.get("customerGroupShowEditCommand")
    $name        = template.ui.$customerGroupName
    $description = template.ui.$customerGroupDescription
    editOptions = {name: $name.val(), description: $description.val()}

    groupFound = Schema.customerGroups.findOne({name: editOptions.name, merchant: Merchant.getId()})
    if editOptions.name.length is 0
      $name.notify("Tên khách hàng không thể để trống.", {position: "right"})
    else if groupFound and groupFound._id isnt group._id
      $name.notify("Tên khách hàng đã tồn tại.", {position: "right"})
      $name.val editOptions.name
      Session.set("customerGroupShowEditCommand", false)
    else
      Schema.customerGroups.update group._id, {$set: editOptions}, (error, result) -> if error then console.log error
      $name.val editOptions.name
      Session.set("customerGroupShowEditCommand", false)


scope.addCustomer = (customerId)->
  customer = Schema.customers.findOne(customerId)
  group = Schema.customerGroups.findOne({isBase: true})
  if customer and group
    Schema.customers.update customer._id, $set: {group: group._id}
    Schema.customerGroups.update group._id, $addToSet: {customers: customer._id }