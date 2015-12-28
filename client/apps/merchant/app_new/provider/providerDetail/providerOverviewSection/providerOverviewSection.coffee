scope = {}
Wings.defineApp 'providerOverviewSection',
  created: ->
    self = this
    self.isEditMode           = new ReactiveVar(false)
    self.isShowEditCommand    = new ReactiveVar(false)
    self.isShowProviderDetail = new ReactiveVar(false)

    self.autorun ()->
      if Session.get('mySession')?.currentProvider
        self.isEditMode.set false
        self.isShowEditCommand.set false
        self.isShowProviderDetail.set false


  rendered: ->
    scope.overviewTemplateInstance = @
    @ui.$providerName.autosizeInput({space: 10}) if @ui.$providerName
  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Template.instance().isShowProviderDetail.get() is text then '' else 'hidden'

    isEditMode: (text)->
      if Template.instance().isEditMode.get() is text then '' else 'hidden'

    showSyncProvider: ->
      if Template.instance().isShowEditCommand.get() and Template.instance().isEditMode.get() then '' else 'hidden'

    showDeleteProvider: ->
      if Template.instance().isEditMode.get() and @allowDelete then '' else 'hidden'

    name: ->
      Meteor.setTimeout ->
        scope.overviewTemplateInstance.ui.$providerName.change()
      ,50 if scope.overviewTemplateInstance?.ui.$providerName?
      @name

  events:
    "click .providerDelete": (event, template) ->
      console.log 'is delete'

    "click .editProvider": (event, template) ->
      Template.instance().isEditMode.set(true)
      Template.instance().isShowProviderDetail.set(true)


    "click .syncProviderEdit": (event, template) ->
      editProvider(template)

    "click .cancelProvider": (event, template) ->
      Template.instance().isEditMode.set(false)


    "click span.hideTab": (event, template)->
      Template.instance().isShowProviderDetail.set(false)


    "click span.showTab": (event, template)->
      Template.instance().isShowProviderDetail.set(true)




    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      updateProviderChangeAvatar(event, template)



    'input input.providerEdit, switchChange.bootstrapSwitch input[name="genderSwitch"]': (event, template) ->
      checkAllowUpdateProviderOverview(template)

    "keyup input.providerEdit": (event, template) ->
      if event.which is 13 and template.data
        editProvider(template)
      else if event.which is 27 and template.data
        rollBackProviderData(event, template)
      checkAllowUpdateProviderOverview(template)


#----------------------------------------------------------------------------------------------------------------------


checkAllowUpdateProviderOverview = (template) ->
  providerData        = template.data
  providerName        = template.ui.$providerName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  providerPhone       = template.ui.$providerPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
  providerCode        = template.ui.$providerCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
  providerAddress     = template.ui.$providerAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
  providerDescription = template.ui.$providerDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Template.instance().isShowEditCommand.set(
    providerName isnt providerData.name or
      providerCode isnt (providerData.code ? '') or
      providerPhone isnt (providerData.phone ? '') or
      providerAddress isnt (providerData.address ? '') or
      providerDescription isnt (providerData.profiles.description ? '')
  )


rollBackProviderData = (event, template)->
  providerData = template.data
  if $(event.currentTarget).attr('name') is 'providerName'
    $(event.currentTarget).val(providerData.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'providerCode'
    $(event.currentTarget).val(providerData.code)
  else if $(event.currentTarget).attr('name') is 'providerPhone'
    $(event.currentTarget).val(providerData.phone)
  else if $(event.currentTarget).attr('name') is 'providerAddress'
    $(event.currentTarget).datepicker('setDate', providerData.dateOfBirth)
  else if $(event.currentTarget).attr('name') is 'providerDescription'
    $(event.currentTarget).val(providerData.description)
  else if $(event.currentTarget).attr('name') is 'providerRepresentative'
    $(event.currentTarget).val(providerData.representative)

updateProviderChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; provider = Template.currentData()
    if files.length > 0 and provider?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Schema.providers.update(provider._id, {$set: {avatar: fileObj._id}})
        AvatarImages.findOne(provider.avatar)?.remove()

editProvider = (template) ->
  provider  = template.data
  summaries = Session.get('merchant')?.summaries
  listCodes = summaries.listProviderCodes ? []
  if provider and Template.instance().isShowEditCommand.get()
    name            = template.ui.$providerName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    phone           = template.ui.$providerPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
    code            = template.ui.$providerCode.val().replace(/^\s*/, "").replace(/\s*$/, "")
    address         = template.ui.$providerAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
    representative  = template.ui.$providerRepresentative.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description     = template.ui.$providerDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")

    editOptions = {}
    editOptions.name            = name if name isnt provider.name
    editOptions.phone           = phone if phone isnt provider.phone
    editOptions.code            = code if code isnt provider.code
    editOptions.address         = address if address isnt provider.address
    editOptions.description     = description if description isnt provider.description
    editOptions.representative  = representative if representative isnt provider.representative


    if editOptions.name isnt undefined  and editOptions.name.length is 0
      template.ui.$providerName.notify("Tên khách hàng không thể để trống.", {position: "right"})

    else if editOptions.code isnt undefined
      if editOptions.code.length > 0
        if listCodes.length > 0 and _.indexOf(listCodes, editOptions.code) isnt -1
          return template.ui.$providerCode.notify("Mã khách hàng đã tồn tại.123123123", {position: "right"})
      else
        return template.ui.$providerCode.notify("Mã khách hàng không thể để trống.", {position: "right"})


    if _.keys(editOptions).length > 0
      Schema.providers.update provider._id, {$set: editOptions}, (error, result) -> if error then console.log error
      Template.instance().isEditMode.set false
      Template.instance().isShowEditCommand.set false
      toastr["success"]("Cập nhật nhà cung cấp thành công.")
