#scope = logics.customerGroup
#currentProductGroup = {}
#Wings.defineApp 'customerGroupOverviewSection',
#  created: ->
##    self = this
##    self.newProductData = new ReactiveVar({})
##    self.autorun ()->
#  rendered: ->
#    Session.set('customerGroupManagementIsShowProductDetail', false)
#    Session.set("customerGroupManagementShowEditCommand", false)
#    Session.set('customerGroupManagementIsEditMode', false)
#
#    #    scope.overviewTemplateInstance = @
#    @ui.$customerGroupName.autosizeInput({space: 10}) if @ui.$customerGroupName
##    changeProductReadonly = if Session.get("customerSelectLists") then Session.get("customerSelectLists").length is 0 else true
##    $(".changeProduct").select2("readonly", changeProductReadonly)
#  destroyed: ->
#
#
#  helpers:
#    isShowTab: (text)->
#      if Session.equals("customerGroupManagementIsShowProductDetail", text) then '' else 'hidden'
#
#    isEditMode: (text)->
#      if Session.equals("customerGroupManagementIsEditMode", text) then '' else 'hidden'
#
#    showSyncProductGroup: ->
#      editCommand = Session.get("customerGroupManagementShowEditCommand")
#      editMode = Session.get("customerGroupManagementIsEditMode")
#      if editCommand and editMode then '' else 'hidden'
#
#    showDeleteProductGroup: ->
#      editMode = Session.get("customerGroupManagementIsEditMode")
#      if editMode and @allowDelete then '' else 'hidden'
#
#    customerGroupSelected: ->
#      currentProductGroup = Template.currentData()
#      customerGroupSelects
#
#  events:
#    "click .deleteProductGroup": (event, template) ->
#      console.log 'is delete'
#
#    "click .unLockEditProduct": (event, template) ->
#      clickShowProductGroupDetailTab(event, template)
#
#    "click .syncEditProductGroup": (event, template) ->
#      editProductGroup(template)
#
#    "click .cancelEditProductGroup": (event, template) ->
#      Session.set('customerGroupManagementIsEditMode', false)
#
#
#
#    "click span.hideTab": (event, template)->
#      Session.set('customerGroupManagementIsShowProductDetail', false)
#    "click span.showTab": (event, template)->
#      clickShowProductGroupDetailTab(event, template)
#
#
##
##    "click .avatar": (event, template) ->
##      if User.hasManagerRoles()
##        template.find('.avatarFile').click()
##
##    "change .avatarFile": (event, template) ->
##      updateProductGroupChangeAvatar(event, template)
#
#
#
#    'input input.customerGroupEdit': (event, template) ->
#      checkAllowUpdateProductGroupOverview(template)
#
#    "keyup input.customerGroupEdit": (event, template) ->
#      if event.which is 13 and template.data
#        editProductGroup(template)
#      else if event.which is 27 and template.data
#        rollBackProductGroupData(event, template)
#      checkAllowUpdateProductGroupOverview(template)
#
#
#
##----------------------------------------------------------------------------------------------------------------------
#clickShowProductGroupDetailTab = (event, template)->
#  Session.set('customerGroupManagementIsShowProductDetail', true)
#  Session.set('customerGroupManagementIsEditMode', true)
#
#checkAllowUpdateProductGroupOverview = (template) ->
#  customerGroupData        = template.data
#  customerGroupName        = template.ui.$customerGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
#  customerGroupDescription = template.ui.$customerGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
#
#  Session.set "customerGroupManagementShowEditCommand",
#    customerGroupName isnt customerGroupData.name or
#      customerGroupDescription isnt (customerGroupData.description ? '')
#
#
#rollBackProductGroupData = (event, template)->
#  customerGroupData = template.data
#  if $(event.currentTarget).attr('name') is 'customerGroupName'
#    $(event.currentTarget).val(customerGroupData.name)
#    $(event.currentTarget).change()
#  else if $(event.currentTarget).attr('name') is 'customerGroupDescription'
#    $(event.currentTarget).val(customerGroupData.description)
#
#updateProductGroupChangeAvatar = (event, template)->
#  if User.hasManagerRoles()
#    files = event.target.files; customerGroup = Template.currentData()
#    if files.length > 0 and customerGroup?._id
#      AvatarImages.insert files[0], (error, fileObj) ->
#        Schema.customerGroups.update(customerGroup._id, {$set: {avatar: fileObj._id}})
#        AvatarImages.findOne(customerGroup.avatar)?.remove()
#
#editProductGroup = (template) ->
#  customerGroup  = template.data
#  if customerGroup and Session.get("customerGroupManagementShowEditCommand")
#    name        = template.ui.$customerGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
#    description = template.ui.$customerGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
#
#    editOptions = {}
#    editOptions.name          = name if name isnt customerGroup.name
#    editOptions.description   = description if description isnt customerGroup.description
#
#    if _.keys(editOptions).length > 0
#      Schema.customerGroups.update customerGroup._id, {$set: editOptions}, (error, result) -> if error then console.log error
#      Session.set("customerGroupManagementShowEditCommand", false)
#      Session.set('customerGroupManagementIsEditMode', false)
#      toastr["success"]("Cập nhật nhóm khách hàng.")
#
#
#customerGroupSelects =
#  query: (query) -> query.callback
#    results: Schema.customerGroups.find(
#      {$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not: currentProductGroup._id }}]}
#    ,
#      {sort: {nameSearch: 1, name: 1}}
#    ).fetch()
#    text: 'name'
#  initSelection: (element, callback) -> callback 'skyReset'
#  formatSelection: (item) -> "#{item.name}" if item
#  formatResult: (item) -> "#{item.name}" if item
#  id: '_id'
#  placeholder: 'Chọn nhóm'
#  changeAction: (e) ->
#    if User.hasManagerRoles()
#      Session.set("customerGroupSelectGroup", 'selectChange')
#      currentProductGroup.changeProductTo(e.added._id)
#      Session.set("customerGroupSelectGroup", 'skyReset')
#  reactiveValueGetter: -> 'skyReset' if Session.get("customerGroupSelectGroup")