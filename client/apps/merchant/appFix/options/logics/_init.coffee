logics.merchantOptions = {} unless logics.merchantOptions
scope = logics.merchantOptions

scope.checkUpdateAccountOption = (template) ->
  if Session.get("myProfile")
    Session.set "merchantAccountOptionShowEditCommand",
      template.ui.$fullName.val() isnt (Session.get("myProfile").name ? '') or
      Session.get("merchantAccountOptionsGenderSelection") isnt (Session.get("myProfile").gender) or
      template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates[0]?.toDateString() isnt (Session.get("myProfile").dateOfBirth?.toDateString() ? undefined) or
      template.ui.$address.val() isnt (Session.get("myProfile").address ? '') #or
#        template.ui.$emailAccount.val() isnt (Session.get("myProfile").email ? '') or
#        template.ui.$im.val() isnt (Session.get("myProfile").im ? '')

scope.updateAccountOption = (template)->
  if Session.get "merchantAccountOptionShowEditCommand"
    profile     = Session.get("myProfile")
    fullName    = template.ui.$fullName.val()
    gender      = Session.get("merchantAccountOptionsGenderSelection")
    dateOfBirth = template.datePicker.$dateOfBirth.datepicker().data().datepicker.dates[0]
    address     = template.ui.$address.val()
#      email       = template.ui.$emailAccount.val()
#      im          = template.ui.$im.val()

    option = $set:{}
    option.$set['profile.name']        = fullName if fullName isnt (profile.name ? '')
    option.$set['profile.gender']      = gender if gender isnt profile.gender
    option.$set['profile.dateOfBirth'] = dateOfBirth if dateOfBirth?.toDateString() isnt (profile.dateOfBirth?.toDateString() ? undefined)
    option.$set['profile.address']     = address if address isnt (profile.address ? '')
#      accountProfileOption.email       = email if email isnt (profile.email ? '')
#      accountProfileOption.im          = im if im isnt (profile.im ? '')

    Meteor.users.update(Meteor.userId(), option)
    Session.set "merchantAccountOptionShowEditCommand"

scope.checkAccountChangePassword = (template) ->
  if Session.get("myProfile")
    oldPassword     = template.ui.$oldPassword.val()
    newPassword     = template.ui.$newPassword.val()
    confirmPassword = template.ui.$confirmPassword.val()

    if oldPassword.length > 0 and newPassword.length > 0 and  newPassword is confirmPassword
      Session.set "merchantAccountOptionChangePasswordCommand", true
    else
      Session.set "merchantAccountOptionChangePasswordCommand"


scope.updateAccountOptionChangePassword = (template)->
  if Session.get("merchantAccountOptionChangePasswordCommand")
    oldPassword     = template.ui.$oldPassword
    newPassword     = template.ui.$newPassword
    confirmPassword = template.ui.$confirmPassword

    if oldPassword.val().length > 0 and newPassword.val().length > 0 and  newPassword.val() is confirmPassword.val()
      Accounts.changePassword oldPassword.val(), newPassword.val(), (error) ->
        if error
           console.log error
        else
          oldPassword.val('')
          newPassword.val('')
          confirmPassword.val('')

          Session.set "merchantAccountOptionChangePasswordCommand"
          console.log 'Thay đổi mật khẩu thành công.'


settings = scope.settings = {}


settings.account = [
  display: "tài khoản"
  icon: "icon-user-7"
  template: "merchantAccountOptions"
  data: Session.get("myProfile")
,
  display: "ghi chú"
  icon: "icon-code-outline"
  template: "merchantNoteOptions"
  data: Session.get("myProfile")
]

settings.merchant = [
  display: "đại lý"
  icon: "icon-shop"
  template: "merchantInfoOptions"
  data: Session.get("merchant")
,
  display: "kho hàng"
  icon: "icon-cubes"
  template: "warehouseInfoOptions"
  data: Session.get("myProfile")
,
  display: "phân quyền"
  icon: "icon-group"
  template: "merchantHROptions"
  data: Session.get("myProfile")
]

settings.system = [
  display: "tùy chỉnh"
  icon: "icon-tools"
  template: "merchantSystemOptions"
  data: Session.get("myProfile")

#,
#  display: "ngôn ngữ"
#  icon: "icon-location-1"
#  template: "merchantLanguageOptions"
#  data: undefined
#,
#  display: "trò chuyện"
#  icon: "icon-chat-6"
#  template: "merchantMessengerOptions"
#  data: undefined
#,
#  display: "nhắc nhở"
#  icon: "icon-bell"
#  template: "merchantNotificationOptions"
#  data: undefined
]

settings.printing = [
  display: "mẫu in"
  icon: "blue icon-clipboard"
  template: "merchantPrintDesigner"
  data: undefined
]

settings.apps = [
#    display: "bán hàng - giao hàng"
#    icon: "orange icon-tags"
#    template: "merchantSaleOptions"
#    data: undefined
#  ,
#    display: "kho - nhập kho"
#    icon: "green-sea icon-download-outline"
#    template: "merchantImportOptions"
#    data: undefined
#  ,
#    display: "khách hàng"
#    icon: "lime icon-contacts"
#    template: "merchantCustomerOptions"
#    data: undefined
#  ,
#    display: "nhà cung cấp"
#    icon: "carrot icon-anchor-outline"
#    template: "merchantProviderOptions"
#    data: undefined
]

settings.staff = [
  display: "nhân sự"
  icon: "icon-group"
  template: "merchantStaffOptions"
  data: Session.get("myProfile")
,
  display: "phân quyền"
  icon: "icon-group"
  template: "merchantHROptions"
  data: Session.get("myProfile")
]
