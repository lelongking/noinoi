scope = logics.staffManagement
Enums = Apps.Merchant.Enums
Wings.defineApp 'staffManagement',
  helpers:
    staffSearcher: ->
      selector = {}; options  = {sort: {'emails.address': 1}}; searchText = Session.get("staffManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {'emails.address': regExp}
        ]}
      scope.staffSearcher = Meteor.users.find(selector, options).fetch()
      scope.staffSearcher

    currentStaff: -> Session.get('staffManagementCurrentStaff')
    getEmails: -> @emails?[0].address
    avatarUrl: -> if @profile and @profile.image then AvatarImages.findOne(@profile.image)?.url() else undefined
    permission: -> Enums.getObject('PermissionType', 'value')[@profile.roles].display

  created: ->
    self = this
    self.autorun ()->
      if staffId = Session.get("mySession")?.currentStaff
        scope.currentStaff = Meteor.users.findOne(staffId)
        Session.set("staffManagementCurrentStaff", scope.currentStaff)
        Session.set "customerOfStaffSelectLists", Session.get('mySession').customerOfStaffSelected?[staffId] ? []

      if staff = Session.get('staffManagementCurrentStaff')
        $(".roleSelect").select2("readonly", unless staff.creator then true else false)
      else
        $(".roleSelect").select2("readonly", true)
        $(".genderSelect").select2("readonly", true)
        $(".changeCustomer").select2("readonly", true)

      if Session.get('customerOfStaffSelectLists')
        $(".changeCustomer").select2("readonly", Session.get('customerOfStaffSelectLists').length < 1)

      if countCustomer = Session.get('staffManagementCustomerListNotOfStaffSelect')
        Session.set('addCustomerToStaffIsDisabled', if countCustomer.length > 0 then '' else 'disabled')

    Session.set("staffManagementSearchFilter", "")
    Session.set("staffManagementCreationMode", false)

  events:
    #search or create staff (if enter)
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        Session.set("staffManagementSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        #else if event.which is 38 then scope.CustomerSearchFindPreviousCustomer(staffSearch)
        #else if event.which is 40 then scope.CustomerSearchFindNextCustomer(staffSearch)
        else
          scope.createNewStaff(template) if event.which is 13
          scope.staffManagementCreationMode()
      , "staffManagementSearchPeople"
      , 50


    #select staff
    "click .inner.caption": (event, template) ->
      if userId = Meteor.userId()
        Meteor.users.update(userId, {$set: {'sessions.currentStaff': @_id}})
        Session.set('showCustomerListNotOfStaff', false)
        Session.set('staffManagementCustomerListNotOfStaffSelect', [])