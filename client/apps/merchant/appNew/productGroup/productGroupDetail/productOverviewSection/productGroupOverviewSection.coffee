scope = logics.productGroup
currentCustomerGroup = {}
Wings.defineApp 'productGroupOverviewSection',
  created: ->
#    self = this
#    self.newCustomerData = new ReactiveVar({})
#    self.autorun ()->
  rendered: ->
    Session.set('productGroupManagementIsShowCustomerDetail', false)
    Session.set("productGroupManagementShowEditCommand", false)
    Session.set('productGroupManagementIsEditMode', false)

#    scope.overviewTemplateInstance = @
    @ui.$productGroupName.autosizeInput({space: 10}) if @ui.$productGroupName
#    changeCustomerReadonly = if Session.get("productSelectLists") then Session.get("productSelectLists").length is 0 else true
#    $(".changeCustomer").select2("readonly", changeCustomerReadonly)
  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Session.equals("productGroupManagementIsShowCustomerDetail", text) then '' else 'hidden'

    isEditMode: (text)->
      if Session.equals("productGroupManagementIsEditMode", text) then '' else 'hidden'

    showSyncCustomerGroup: ->
      editCommand = Session.get("productGroupManagementShowEditCommand")
      editMode = Session.get("productGroupManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteCustomerGroup: ->
      editMode = Session.get("productGroupManagementIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'

    productGroupSelected: ->
      currentCustomerGroup = Template.currentData()
      productGroupSelects

  events:
    "click .deleteCustomerGroup": (event, template) ->
      console.log 'is delete'

    "click .unLockEditCustomer": (event, template) ->
      clickShowCustomerGroupDetailTab(event, template)

    "click .syncEditCustomerGroup": (event, template) ->
      editCustomerGroup(template)

    "click .cancelEditCustomerGroup": (event, template) ->
      Session.set('productGroupManagementIsEditMode', false)



    "click span.hideTab": (event, template)->
      Session.set('productGroupManagementIsShowCustomerDetail', false)
    "click span.showTab": (event, template)->
      clickShowCustomerGroupDetailTab(event, template)


#
#    "click .avatar": (event, template) ->
#      if User.hasManagerRoles()
#        template.find('.avatarFile').click()
#
#    "change .avatarFile": (event, template) ->
#      updateCustomerGroupChangeAvatar(event, template)



    'input input.productGroupEdit': (event, template) ->
      checkAllowUpdateCustomerGroupOverview(template)

    "keyup input.productGroupEdit": (event, template) ->
      if event.which is 13 and template.data
        editCustomerGroup(template)
      else if event.which is 27 and template.data
        rollBackCustomerGroupData(event, template)
      checkAllowUpdateCustomerGroupOverview(template)



#----------------------------------------------------------------------------------------------------------------------
clickShowCustomerGroupDetailTab = (event, template)->
  Session.set('productGroupManagementIsShowCustomerDetail', true)
  Session.set('productGroupManagementIsEditMode', true)

checkAllowUpdateCustomerGroupOverview = (template) ->
  productGroupData        = template.data
  productGroupName        = template.ui.$productGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productGroupDescription = template.ui.$productGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Session.set "productGroupManagementShowEditCommand",
    productGroupName isnt productGroupData.name or
      productGroupDescription isnt (productGroupData.description ? '')


rollBackCustomerGroupData = (event, template)->
  productGroupData = template.data
  if $(event.currentTarget).attr('name') is 'productGroupName'
    $(event.currentTarget).val(productGroupData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'productGroupDescription'
    $(event.currentTarget).val(productGroupData.description)

updateCustomerGroupChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; productGroup = Template.currentData()
    if files.length > 0 and productGroup?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.productGroups.update(productGroup._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(productGroup.avatar)?.remove()

editCustomerGroup = (template) ->
  productGroup  = template.data
  if productGroup and Session.get("productGroupManagementShowEditCommand")
    name        = template.ui.$productGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description = template.ui.$productGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

    editOptions = {}
    editOptions.name          = name if name isnt productGroup.name
    editOptions.description   = description if description isnt productGroup.description

    if _.keys(editOptions).length > 0
      Schema.productGroups.update productGroup._id, {$set: editOptions}, (error, result) -> if error then console.log error
      Session.set("productGroupManagementShowEditCommand", false)
      Session.set('productGroupManagementIsEditMode', false)
      toastr["success"]("Cập nhật nhóm khách hàng.")


productGroupSelects =
  query: (query) -> query.callback
    results: Schema.productGroups.find(
      {$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not: currentCustomerGroup._id }}]}
    ,
      {sort: {nameSearch: 1, name: 1}}
    ).fetch()
    text: 'name'
  initSelection: (element, callback) -> callback 'skyReset'
  formatSelection: (item) -> "#{item.name}" if item
  formatResult: (item) -> "#{item.name}" if item
  id: '_id'
  placeholder: 'Chọn nhóm'
  changeAction: (e) ->
    if User.hasManagerRoles()
      Session.set("productGroupSelectGroup", 'selectChange')
      currentCustomerGroup.changeCustomerTo(e.added._id)
      Session.set("productGroupSelectGroup", 'skyReset')
  reactiveValueGetter: -> 'skyReset' if Session.get("productGroupSelectGroup")