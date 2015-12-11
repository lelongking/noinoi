scope = logics.customerGroup
formatCustomerSearch = (item) -> "#{item.name}" if item
Wings.defineApp 'customerGroupOverviewSection',
  created: ->
#    self = this
#    self.newCustomerData = new ReactiveVar({})
#    self.autorun ()->
  rendered: ->
    Session.set('customerGroupManagementIsShowCustomerDetail', false)
    Session.set("customerGroupManagementShowEditCommand", false)
    Session.set('customerGroupManagementIsEditMode', false)

    scope.overviewTemplateInstance = @
    @ui.$customerGroupName.autosizeInput({space: 10}) if @ui.$customerGroupName
#    changeCustomerReadonly = if Session.get("customerSelectLists") then Session.get("customerSelectLists").length is 0 else true
#    $(".changeCustomer").select2("readonly", changeCustomerReadonly)
  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Session.equals("customerGroupManagementIsShowCustomerDetail", text) then '' else 'hidden'

    isEditMode: (text)->
      if Session.equals("customerGroupManagementIsEditMode", text) then '' else 'hidden'

    showSyncCustomerGroup: ->
      editCommand = Session.get("customerGroupManagementShowEditCommand")
      editMode = Session.get("customerGroupManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteCustomerGroup: ->
      editMode = Session.get("customerGroupManagementIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$customerGroupName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$customerGroupName?
      @name


    customerGroupSelects: ->
      query: (query) -> query.callback
        results: Schema.customerGroups.find({$or: [{name: Helpers.BuildRegExp(query.term), _id: {$not:template.data._id }}]}).fetch()
        text: 'name'
      initSelection: (element, callback) -> callback 'skyReset'
      formatSelection: formatCustomerSearch
      formatResult: formatCustomerSearch
      id: '_id'
      placeholder: 'Chuyển nhóm'
      changeAction: (e) -> scope.currentCustomerGroup.changeCustomerTo(e.added._id) if User.hasManagerRoles()
      reactiveValueGetter: -> 'skyReset'

  events:
    "click .deleteCustomerGroup": (event, template) ->
      console.log 'is delete'

    "click .unLockEditCustomer": (event, template) ->
      clickShowCustomerGroupDetailTab(event, template)

    "click .syncEditCustomerGroup": (event, template) ->
      editCustomer(template)

    "click .cancelEditCustomerGroup": (event, template) ->
      Session.set('customerGroupManagementIsEditMode', false)



    "click span.hideTab": (event, template)->
      Session.set('customerGroupManagementIsShowCustomerDetail', false)
    "click span.showTab": (event, template)->
      clickShowCustomerGroupDetailTab(event, template)



    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      updateCustomerGroupChangeAvatar(event, template)



    'input input.customerGroupEdit': (event, template) ->
      checkAllowUpdateCustomerGroupOverview(template)

    "keyup input.customerGroupEdit": (event, template) ->
      if event.which is 13 and template.data
        editCustomerGroup(template)
      else if event.which is 27 and template.data
        rollBackCustomerGroupData(event, template)
      checkAllowUpdateCustomerGroupOverview(template)

#----------------------------------------------------------------------------------------------------------------------
clickShowCustomerGroupDetailTab = (event, template)->
  Session.set('customerGroupManagementIsShowCustomerDetail', true)
  Session.set('customerGroupManagementIsEditMode', true)

checkAllowUpdateCustomerGroupOverview = (template) ->
  customerGroupData        = template.data
  customerGroupName        = template.ui.$customerGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  customerGroupDescription = template.ui.$customerGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Session.set "customerGroupManagementShowEditCommand",
    customerGroupName isnt customerGroupData.name or
      customerGroupDescription isnt (customerGroupData.description ? '')


rollBackCustomerGroupData = (event, template)->
  customerGroupData = template.data
  if $(event.currentTarget).attr('name') is 'customerGroupName'
    $(event.currentTarget).val(customerGroupData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'customerGroupDescription'
    $(event.currentTarget).val(customerGroupData.description)

updateCustomerGroupChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; customerGroup = Template.currentData()
    if files.length > 0 and customerGroup?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.customerGroups.update(customerGroup._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(customerGroup.avatar)?.remove()

editCustomerGroup = (template) ->
  customerGroup  = template.data
  if customerGroup and Session.get("customerGroupManagementShowEditCommand")
    name        = template.ui.$customerGroupName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description = template.ui.$customerGroupDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

    editOptions = {}
    editOptions.name          = name if name isnt customerGroup.name
    editOptions.description   = description if description isnt customerGroup.description

    if _.keys(editOptions).length > 0
      Schema.customerGroups.update customerGroup._id, {$set: editOptions}, (error, result) -> if error then console.log error
      Session.set("customerGroupManagementShowEditCommand", false)
      Session.set('customerGroupManagementIsEditMode', false)
      toastr["success"]("Cập nhật nhóm khách hàng.")


