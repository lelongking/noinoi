Enums = Apps.Merchant.Enums
Wings.defineHyper 'staffCreate',
  created: ->
    Session.set("staffCreateSelectedGroup", 'skyReset')

  rendered: ->
    self = this
    self.ui.$genderSwitch.bootstrapSwitch('onText', 'Nam')
    self.ui.$genderSwitch.bootstrapSwitch('offText', 'Nữ')

    self.ui.$staffUserName.select()

  destroyed: ->
    Session.set("staffCreateSelectedGroup")


#  helpers:
#    staffPermissionSelect: -> staffCreateSelectPermission

  events:
    "click .cancelStaff": (event, template) ->
      FlowRouter.go('staff')

    "click .addStaff": (event, template) ->
      addNewStaff(event, template)

    "blur": (event, template) ->
      if event.target.name is "staffUserName"
        checkStaffUserName(event, template)
      else if event.target.name is "staffPassword"
        checkStaffPassword(event, template)
      else if event.target.name is "staffConfirmPassword"
        checkStaffConfirmPassword(event, template)


#staffCreateSelectPermission =
#  query: (query) -> query.callback
#    results: Enums.PermissionType
#    text: 'name'
#  initSelection: (element, callback) -> callback Session.get("staffCreateSelectedGroup") ? 'skyReset'
#  formatSelection: (item) -> "#{item.display}" if item
#  formatResult: (item) -> "#{item.display}" if item
#  id: 'value'
#  placeholder: 'Chọn phân quyền'
#  changeAction: (e) -> Session.set("staffCreateSelectedGroup", e.added)
#  reactiveValueGetter: -> Session.get("staffCreateSelectedGroup") ? 'skyReset'



checkStaffUserName = (event, template, staff) ->
  $staffUserName = template.ui.$staffUserName
  staffUserName  = $staffUserName.val().replace(/^\s*/, "").replace(/\s*$/, "")

  if staffUserName.length > 0
    $staffUserName.removeClass('error')
    if Meteor.users.findOne({'emails.address': staffUserName})
      $staffUserName.addClass('error')
      template.ui.$searchFilter.notify("Tên nhân viên đã tồn tại.", {position: "right"})
    else
      staff.username = staffUserName if staff
  else
    $staffUserName.addClass('error')
    $staffUserName.notify('Tài khoản không được để trống', {position: "right"})
    return false



checkStaffPassword = (event, template, staff) ->
  $staffPassword = template.ui.$staffPassword
  staffPassword  = $staffPassword.val().replace(/^\s*/, "").replace(/\s*$/, "")

  if staffPassword.length > 4
    $staffPassword.removeClass('error')
    staff.password = staffPassword if staff
  else
    $staffPassword.addClass('error')
    $staffPassword.notify('Mật khẩu quá ngắn', {position: "right"})
    return false


checkStaffConfirmPassword = (event, template, staff) ->
  $staffPassword = template.ui.$staffPassword
  staffPassword  = $staffPassword.val().replace(/^\s*/, "").replace(/\s*$/, "")

  $staffConfirmPassword = template.ui.$staffConfirmPassword
  staffConfirmPassword  = $staffConfirmPassword.val().replace(/^\s*/, "").replace(/\s*$/, "")

  if staffPassword is staffConfirmPassword
    $staffConfirmPassword.removeClass('error')
    staff.confirmPassword = staffConfirmPassword if staff
  else
    $staffConfirmPassword.addClass('error')
    $staffConfirmPassword.notify('Mật khẩu không chính xác', {position: "right"})
    return false




addNewStaff = (event, template, staff = {}) ->
  if checkStaffUserName(event, template, staff)
    if checkStaffPassword(event, template, staff)
      if checkStaffConfirmPassword(event, template, staff)
        staff.profile = {}

        $staffName = template.ui.$staffName
        staffName  = $staffName.val().replace(/^\s*/, "").replace(/\s*$/, "")
        staff.profile.name = staffName if staffName

        $staffPhone = template.ui.$staffPhone
        staffPhone  = $staffPhone.val().replace(/^\s*/, "").replace(/\s*$/, "")
        staff.profile.phone = staffPhone if staffPhone

        $staffAddress = template.ui.$staffAddress
        staffAddress  = $staffAddress.val().replace(/^\s*/, "").replace(/\s*$/, "")
        staff.profile.address = staffAddress if staffAddress

        staffGender = template.ui.$genderSwitch.bootstrapSwitch('state')
        staff.profile.gender = staffGender


        staffBirth  = template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates.get()
        staff.profile.dateOfBirth = staffBirth if staffBirth

        $staffDescription = template.ui.$staffDescription
        staffDescription  = $staffDescription.val().replace(/^\s*/, "").replace(/\s*$/, "")
        staff.profile.description = staffDescription if staffDescription.length > 0


        console.log staff
        Meteor.call "createUserByEmail", staff.username, staff.password, staff.profile, (error, result) ->
          if result
            FlowRouter.go('staff')
            Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentStaff': result}})
            toastr["success"]("Tạo nhân sự thành công.")




