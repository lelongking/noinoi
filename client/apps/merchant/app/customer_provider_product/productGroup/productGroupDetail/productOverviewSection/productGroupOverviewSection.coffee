scope = logics.productGroup
currentProductGroup = {}
Wings.defineApp 'productGroupOverviewSection',
  created: ->
#    self = this
#    self.newProductData = new ReactiveVar({})
#    self.autorun ()->
  rendered: ->
    Session.set('productGroupManagementIsShowProductDetail', false)
    Session.set("productGroupManagementShowEditCommand", false)
    Session.set('productGroupManagementIsEditMode', false)

#    scope.overviewTemplateInstance = @
    @ui.$productGroupName.autosizeInput({space: 10}) if @ui.$productGroupName
#    changeProductReadonly = if Session.get("productSelectLists") then Session.get("productSelectLists").length is 0 else true
#    $(".changeProduct").select2("readonly", changeProductReadonly)
  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Session.equals("productGroupManagementIsShowProductDetail", text) then '' else 'hidden'

    isEditMode: (text)->
      if Session.equals("productGroupManagementIsEditMode", text) then '' else 'hidden'

    showSyncProductGroup: ->
      editCommand = Session.get("productGroupManagementShowEditCommand")
      editMode = Session.get("productGroupManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteProductGroup: ->
      editMode = Session.get("productGroupManagementIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'

    changeProductGroupSelected: ->
      currentProductGroup = Template.currentData()
      productGroupSelects

  events:
    "click .deleteProductGroup": (event, template) ->
      console.log 'is delete'

    "click .unLockEditProduct": (event, template) ->
      clickShowProductGroupDetailTab(event, template)

    "click .syncEditProductGroup": (event, template) ->
      editProductGroup(template)

    "click .cancelEditProductGroup": (event, template) ->
      Session.set('productGroupManagementIsEditMode', false)



    "click span.hideTab": (event, template)->
      Session.set('productGroupManagementIsShowProductDetail', false)
    "click span.showTab": (event, template)->
      clickShowProductGroupDetailTab(event, template)


#
#    "click .avatar": (event, template) ->
#      if User.hasManagerRoles()
#        template.find('.avatarFile').click()
#
#    "change .avatarFile": (event, template) ->
#      updateProductGroupChangeAvatar(event, template)



    'input input.productGroupEdit': (event, template) ->
      checkAllowUpdateProductGroupOverview(template)

    "keyup input.productGroupEdit": (event, template) ->
      if event.which is 13 and template.data
        editProductGroup(template)
      else if event.which is 27 and template.data
        rollBackProductGroupData(event, template)
      checkAllowUpdateProductGroupOverview(template)



#----------------------------------------------------------------------------------------------------------------------
clickShowProductGroupDetailTab = (event, template)->
  Session.set('productGroupManagementIsShowProductDetail', true)
  Session.set('productGroupManagementIsEditMode', true)

checkAllowUpdateProductGroupOverview = (template) ->
  productGroupData        = template.data
  productGroupName        = template.ui.$productGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  productGroupDescription = template.ui.$productGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Session.set "productGroupManagementShowEditCommand",
    productGroupName isnt productGroupData.name or
      productGroupDescription isnt (productGroupData.description ? '')


rollBackProductGroupData = (event, template)->
  productGroupData = template.data
  if $(event.currentTarget).attr('name') is 'productGroupName'
    $(event.currentTarget).val(productGroupData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'productGroupDescription'
    $(event.currentTarget).val(productGroupData.description)

updateProductGroupChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; productGroup = Template.currentData()
    if files.length > 0 and productGroup?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.productGroups.update(productGroup._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(productGroup.avatar)?.remove()

editProductGroup = (template) ->
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
      {$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not: currentProductGroup._id }}]}
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
      currentProductGroup.changeProductTo(e.added._id)
      Session.set("productGroupSelectGroup", 'skyReset')
  reactiveValueGetter: -> 'skyReset' if Session.get("productGroupSelectGroup")