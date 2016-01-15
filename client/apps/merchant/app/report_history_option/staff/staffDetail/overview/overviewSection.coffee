scope = logics.staffManagement

Wings.defineHyper 'staffManagementOverviewSection',
  created: ->
    self = this
    self.autorun ()->

  rendered: ->
    Session.set('staffManagementIsShowStaffDetail', false)
    Session.set("staffManagementShowEditCommand", false)
    Session.set('staffManagementIsEditMode', false)
    console.log Template.currentData()
    console.log Template.parentData()
    console.log Template.instance()

    @ui.$staffName.autosizeInput({space: 10}) if @ui.$staffName
    @ui.$genderSwitch.bootstrapSwitch('onText', 'Nam')
    @ui.$genderSwitch.bootstrapSwitch('offText', 'Nữ')

    if Session.get("staffManagementShowEditCommand")
      $(".changeStaffGroup").select2("readonly", false)
    else
      $(".changeStaffGroup").select2("readonly", true)

    @ui.$staffName.select()

  destroyed: ->


  helpers:
    isShowTab: (text)->
      if Session.equals("staffManagementIsShowStaffDetail", text) then '' else 'hidden'

    isEditMode: (text)->
      if Session.equals("staffManagementIsEditMode", text) then '' else 'hidden'

    showSyncStaff: ->
      editCommand = Session.get("staffManagementShowEditCommand")
      editMode = Session.get("staffManagementIsEditMode")
      if editCommand and editMode then '' else 'hidden'

    showDeleteStaff: ->
      editMode = Session.get("staffManagementIsEditMode")
      if editMode and @allowDelete then '' else 'hidden'


    userName: -> @emails?[0]?.address ? 'chưa tạo tài khoản đăng nhập.'
    genderName: -> if @profile?.gender then 'Nam' else 'Nữ'

  events:
    "click .staffDelete": (event, template) ->
      console.log 'is delete'


    "click .editStaff": (event, template) ->
      console.log template.data
      clickShowStaffDetailTab(event, template)
      Session.set('staffManagementIsEditMode', true)
      template.ui.$genderSwitch.bootstrapSwitch('disabled', !Session.get('staffManagementIsEditMode'))
      checkAllowUpdateOverview(template)

    "click .syncStaffEdit": (event, template) ->
      editStaff(template)

    "click .cancelStaff": (event, template) ->
      Session.set('staffManagementIsEditMode', false)
      template.ui.$genderSwitch.bootstrapSwitch('disabled', !Session.get('staffManagementIsEditMode'))
      dateOfBirth = moment(template.data.profile.dateOfBirth).format("DD/MM/YYYY")
      template.datePicker.$dateOfBirth.datepicker('setDate', dateOfBirth)




    "click span.hideTab": (event, template)->
      Session.set('staffManagementIsShowStaffDetail', false)

    "click span.showTab": (event, template)->
      clickShowStaffDetailTab(event, template)



    "click .avatar": (event, template) ->
      if User.hasManagerRoles()
        template.find('.avatarFile').click()

    "change .avatarFile": (event, template) ->
      updateChangeAvatar(event, template)

    "change [name='dateOfBirth']": (event, template) ->
      checkAllowUpdateOverview(template)

    'input input.staffEdit, switchChange.bootstrapSwitch input[name="genderSwitch"]': (event, template) ->
      checkAllowUpdateOverview(template)

    "keyup input.staffEdit": (event, template) ->
      if event.which is 13 and template.data
        editStaff(template)
      else if event.which is 27 and template.data
        rollBackStaffData(event, template)
      checkAllowUpdateOverview(template)



#----------------------------------------------------------------------------------------------------------------------
clickShowStaffDetailTab = (event, template)->
  staff = template.data
  if template.ui.$genderSwitch
    template.ui.$genderSwitch.bootstrapSwitch('disabled', false)
    template.ui.$genderSwitch.bootstrapSwitch('state', staff.profile.gender)
    template.ui.$genderSwitch.bootstrapSwitch('disabled', !Session.get('staffManagementIsEditMode'))

  if template.datePicker
    dateOfBirth = if staff.profile.dateOfBirth then moment(staff.profile.dateOfBirth).format("DD/MM/YYYY") else ''
    template.datePicker.$dateOfBirth.datepicker('setDate', dateOfBirth)
  Session.set('staffManagementIsShowStaffDetail', true)

  if staff.staffOfGroup
    Session.set("staffCreateSelectedGroup", Schema.staffGroups.findOne({_id: staff.staffOfGroup}))

checkAllowUpdateOverview = (template) ->
  staffData        = template.data

  staffName        = template.ui.$staffName.val().replace(/^\s*/, "").replace(/\s*$/, "")
  staffPhone       = template.ui.$staffPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
  staffAddress     = template.ui.$staffAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
  staffDescription = template.ui.$staffDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
  staffGender      = template.ui.$genderSwitch.bootstrapSwitch('state')
  staffDateOfBirth = template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates.get()
  staffDateOfBirth = moment(staffDateOfBirth).format("DD/MM/YYYY") if staffDateOfBirth


  Session.set "staffManagementShowEditCommand",
    staffName isnt staffData.profile.name or
      staffPhone isnt (staffData.profile.phone ? '') or
      staffGender isnt (staffData.profile.gender ? '') or
      staffAddress isnt (staffData.profile.address ? '') or
      staffDateOfBirth isnt (
        if staffData.profile.dateOfBirth
          moment(staffData.profile.dateOfBirth).format("DD/MM/YYYY")
        else
          undefined
      ) or
      staffDescription isnt (staffData.profile.description ? '')


rollBackStaffData = (event, template)->
  staffData = template.data
  if $(event.currentTarget).attr('name') is 'staffName'
    $(event.currentTarget).val(staffData.profile.name)
    $(event.currentTarget).change()
  else if $(event.currentTarget).attr('name') is 'staffPhone'
    $(event.currentTarget).val(staffData.profile.phone)
  else if $(event.currentTarget).attr('name') is 'genderSwitch'
    $(event.currentTarget).bootstrapSwitch('state', template.data.profile.gender)
  else if $(event.currentTarget).attr('name') is 'staffAddress'
    $(event.currentTarget).val(staffData.profile.address)
  else if $(event.currentTarget).attr('name') is 'dateOfBirth'
    $(event.currentTarget).datepicker('setDate', staffData.profile.dateOfBirth)
  else if $(event.currentTarget).attr('name') is 'staffDescription'
    $(event.currentTarget).val(staffData.profile.description)

updateChangeAvatar = (event, template)->
  if User.hasManagerRoles()
    files = event.target.files; staff = Template.currentData()
    if files.length > 0 and staff?._id
      AvatarImages.insert files[0], (error, fileObj) ->
        Meteor.users.update(staff._id, {$set: {'profile.image': fileObj._id}})
        AvatarImages.findOne(staff.avatar)?.remove()

editStaff = (template) ->
  staff   = template.data
  if staff and Session.get("staffManagementShowEditCommand")
    name            = template.ui.$staffName.val().replace(/^\s*/, "").replace(/\s*$/, "")
    phone           = template.ui.$staffPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
    address         = template.ui.$staffAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
    description     = template.ui.$staffDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
    gender          = template.ui.$genderSwitch.bootstrapSwitch('state')
    dateOfBirth     = template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates.get().toString()


    editOptions = {}
    editOptions['profile.name']        = name if name isnt staff.profile.name
    editOptions['profile.phone']       = phone if phone isnt staff.profile.phone
    editOptions['profile.address']     = address if address isnt staff.profile.address
    editOptions['profile.description'] = description if description isnt staff.profile.description
    editOptions['profile.gender']      = gender if gender isnt staff.profile.gender
    editOptions['profile.dateOfBirth'] = dateOfBirth if dateOfBirth isnt staff.profile.dateOfBirth

    if _.keys(editOptions).length > 0
      Meteor.users.update staff._id, {$set: editOptions}, (error, result) ->
        if error then console.log error


      Session.set("staffManagementShowEditCommand", false)
      Session.set('staffManagementIsEditMode', false)
      template.ui.$genderSwitch.bootstrapSwitch('disabled', true)
      toastr["success"]("Cập nhật nhân sự thành công.")



#    "click .staffDelete": (event, template) ->
#      if staff = Session.get("staffManagementCurrentStaff")
#        if staff.allowDelete and staff._id isnt Session.get('myProfile')._id
#          if Meteor.users.remove(staff._id)
#            Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentStaff': Meteor.users.findOne()?._id ? ''}})

#    "click .addStaffToStaff": (event, template)->
#      if Session.get('showStaffListNotOfStaff')
#        staffId      = Session.get("staffManagementCurrentStaff")._id
#        staffList = Session.get('staffManagementStaffListNotOfStaffSelect')
#        list = []
#
#        if staffId and staffList?.length > 0
#          for staffId in staffList
#            if staff = Schema.staffs.findOne({_id:staffId, staff: {$exists: false} })
#              list.push(staff._id)
#              Schema.staffs.update staff._id, $set:{staff: staffId}
#
#          if list.length > 0
#            Meteor.users.update staffId, $addToSet:{'profile.staffs': {$each: list}}
#            Session.set('showStaffListNotOfStaff', false)
#            Session.set('staffManagementStaffListNotOfStaffSelect', [])