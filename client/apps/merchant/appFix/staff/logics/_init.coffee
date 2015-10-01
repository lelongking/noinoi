logics.staffManagement = {} unless logics.staffManagement
Enums = Apps.Merchant.Enums
scope = logics.staffManagement



scope.staffManagementCreationMode = ->
  if Session.get("staffManagementSearchFilter").length > 0
    if scope.staffSearcher.length is 0 then nameIsExisted = true
    else if scope.staffSearcher.length is 1
      nameIsExisted = scope.staffSearcher[0].emails[0].address isnt Session.get("staffManagementSearchFilter")
  Session.set("staffManagementCreationMode", nameIsExisted)


scope.editStaff = (template) ->
  staff = Session.get("staffManagementCurrentStaff")
  if staff and Session.get("staffManagementShowEditCommand")
    fullText = template.ui.$staffName.val()
    nameOptions = splitName(fullText)

    if nameOptions['profile.name'].length is 0
      template.ui.$staffName.notify("Tên nhân viên không thể để trống.", {position: "right"})
#      else if staffFound and staffFound._id isnt staff._id
#        template.ui.$staffName.notify("Tên nhân viên đã tồn tại.", {position: "right"})
#        template.ui.$staffName.val nameOptions['profile.name']
#        Session.set("staffManagementShowEditCommand", false)
    else
      template.ui.$staffName.val nameOptions['profile.name']
      Session.set("staffManagementShowEditCommand", false)
      Meteor.users.update(staff._id, $set: nameOptions)



splitName = (fullText) ->
  if fullText.indexOf("(") > 0
    namePart    = fullText.substr(0, fullText.indexOf("(")).trim()
    genderPart  = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
    if genderPart.length > 0 then genderPart  = (Helpers.RemoveVnSigns genderPart).toLowerCase()

    option = {'profile.name': namePart }
    option['profile.gender'] = if genderPart is 'nu' then false else true

    return option
  else
    return { 'profile.name': fullText }




scope.createNewStaff = (template) ->
  if Session.get("staffManagementCreationMode")
    email = Session.get("staffManagementSearchFilter")
    staffFound = Meteor.users.findOne({'emails.address': email}) if email.length > 0

    if email.length is 0
      template.ui.$searchFilter.notify("Tên nhân viên không thể để trống.", {position: "right"})

    else if staffFound and staffFound._id isnt staff._id
      template.ui.$searchFilter.notify("Tên nhân viên đã tồn tại.", {position: "right"})
      template.ui.$searchFilter.val email
      Session.set("staffManagementCreationMode", false)

    else
      Meteor.call "createUserByEmail", email, '123', (error, result) ->
        Session.set("staffManagementSearchFilter", ''); template.ui.$searchFilter.val('')
        Session.set("staffManagementCreationMode", false)
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentStaff': result}}) if result


scope.createStaff = (template) ->
  fullText    = Session.get("staffManagementSearchFilter")
  nameOptions = splitName(fullText)

  staff =
    parentMerchant   : Session.get('myProfile').parentMerchant
    currentMerchant  : Session.get('myProfile').currentMerchant
    currentWarehouse : Session.get('myProfile').currentWarehouse
    creator          : Session.get('myProfile').user
    fullName         : nameOptions.fullName
    gender           : nameOptions.gender ? true
    isRoot           : false
    styles           : Helpers.RandomColor()
  staff.gender = nameOptions.gender if nameOptions.gender

  existedQuery = {fullName: nameOptions.fullName, parentMerchant: Session.get('myProfile').parentMerchant}
  #    existedQuery.description = nameOptions.description if nameOptions.description?.length > 0
  if Schema.userProfiles.findOne existedQuery
    template.ui.$searchFilter.notify("Tên nhân viên đã tồn tại.", {position: "bottom"})
  else
    Schema.userProfiles.insert staff, (error, result) ->
      console.log error if error
      MetroSummary.updateMetroSummaryBy(['staff'])
      UserSession.set('currentStaffManagementSelection', result)
    template.ui.$searchFilter.val(''); Session.set("staffManagementSearchFilter", "")




scope.updateEmailOfStaff = (template) ->
  if staffProfile = Session.get("staffManagementCurrentStaff")
    email = $("[name='email']").val()
    password = $("[name='password']").val()
    confirm = $("[name='confirm']").val()

    console.log email
    console.log password
    console.log confirm

    if email.length > 0 and password.length > 0
      if password isnt confirm
        $("[name='confirm']").notify("Mật khẩu không chính xác.", {position: "bottom"})
      else if Meteor.users.findOne({'emails.address': email})
        $("[name='email']").notify("Email đã tồn tại.", {position: "bottom"})
      else
        Meteor.call "updateEmailStaff", email, password, staffProfile._id

splitName = (fullText) ->
  if fullText.indexOf("(") > 0
    namePart    = fullText.substr(0, fullText.indexOf("(")).trim()
    genderPart  = fullText.substr(fullText.indexOf("(")).replace("(", "").replace(")", "").trim()
    if genderPart.length > 0 then genderPart  = (Helpers.RemoveVnSigns genderPart).toLowerCase()

    option = { fullName: namePart }
    option.gender = if genderPart is 'nu' then false else true

    return option
  else
    return { fullName: fullText }


formatGender         = (item) -> "#{item.display}" if item
formatDefaultSearch  = (item) -> "#{item.display}" if item
formatCustomerSearch = (item) -> "#{item.profile.name}" if item
findPermissionType   = (permissionId)-> _.findWhere(Enums.PermissionType, {value: permissionId}) ? 'skyReset'

scope.customerGroupSelects =
  query: (query) -> query.callback
    results: Meteor.users.find({_id: {$not: Session.get("mySession").currentStaff}}).fetch()
    text: 'name'
  initSelection: (element, callback) -> callback 'skyReset'
  formatSelection: formatCustomerSearch
  formatResult: formatCustomerSearch
  id: '_id'
  placeholder: 'CHỌN NHÓM'
  changeAction: (e) ->
    formStaff = Session.get('staffManagementCurrentStaff')
    toStaff   = e.added
    customerList = Session.get('customerOfStaffSelectLists')

    if formStaff and toStaff and customerList.length > 0
      checkCustomerList = []
      for customerId in customerList
        if customer = Schema.customers.findOne({_id:customerId, staff: formStaff._id})
          checkCustomerList.push(customer._id)
          Schema.customers.update customer._id, $set:{staff: toStaff._id}

      userUpdate = $set:{}; userUpdate.$set["sessions.customerOfStaffSelected.#{Session.get("mySession").currentStaff}"] = []
      Meteor.users.update(Meteor.userId(), userUpdate)

      Meteor.users.update(formStaff._id, $pullAll:{'profile.customers': customerList })
      Meteor.users.update(toStaff._id, $addToSet:{'profile.customers': {$each: checkCustomerList}}) if checkCustomerList.length > 0

      Session.set('staffManagementResetCustomerSelect', '')
      Session.set('staffManagementResetCustomerSelect', 'skyReset')
    return false
  reactiveValueGetter: -> Session.get('staffManagementResetCustomerSelect')


scope.roleSelectOptions =
  query: (query) -> query.callback
    results: Enums.PermissionType
    text: 'value'
  initSelection: (element, callback) -> callback findPermissionType(Session.get('staffManagementCurrentStaff')?.profile.roles)
  formatSelection: formatDefaultSearch
  formatResult: formatDefaultSearch
  placeholder: 'CHỌN PHÂN QUYỀN'
  minimumResultsForSearch: -1
  changeAction: (e) -> Meteor.users.update(Session.get("staffManagementCurrentStaff")._id, $set:{'profile.roles': e.added.value})
  reactiveValueGetter: -> findPermissionType(Session.get('staffManagementCurrentStaff')?.profile.roles)


scope.genderSelectOptions =
  query: (query) -> query.callback
    results: Apps.Merchant.Enums.GenderTypes
    text: 'id'
    initSelection: (element, callback) ->
      callback _.findWhere(Apps.Merchant.Enums.GenderTypes, {_id: Session.get("staffManagementCurrentStaff")?.profile.gender})
    reactiveValueGetter: -> _.findWhere(Apps.Merchant.Enums.GenderTypes, {_id: Session.get("staffManagementCurrentStaff")?.profile.gender})
    changeAction: (e) ->
      Meteor.users.update Session.get("staffManagementCurrentStaff")._id, $set: {'profile.gender': e.added._id}

    formatSelection: formatGender
    formatResult: formatGender
    placeholder: 'CHỌN GIỚI TÍNH'
    minimumResultsForSearch: -1