Enums = Apps.Merchant.Enums

Wings.defineHyper 'staffSearch',
  created: ->
    self = this
    self.currentStaff = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if staffId = Session.get('mySession')?.currentStaff
        self.currentStaff.set(Meteor.users.findOne({_id:staffId}))

  rendered: ->

  helpers:
    currentStaff: ->
      Template.instance().currentStaff.get()

    activeClass: ->
      if @_id is Template.instance().currentStaff.get()?._id then 'active' else ''

    staffSearcher: ->
      selector   = {'profile.merchant': Merchant.getId()}
      options    = {sort: {'profile.name': 1, 'emails.address': 1}}
      staffLists = Meteor.users.find(selector, options).fetch()

      staffSearchText = Template.instance().searchFilter.get()
      if staffSearchText?.length > 0
        _.filter staffLists, (staff) ->
          unsignedTerm = Helpers.RemoveVnSigns staffSearchText
          unsignedName = Helpers.RemoveVnSigns (staff.profile.name ? emails.address)
          unsignedName.indexOf(unsignedTerm) > -1
      else
        staffLists


  events:
    "click .create-new-command": (event, template) ->
      FlowRouter.go('createStaff')

    "click .list .doc-item": (event, template) ->
      currentCustomer = @
      selectCustomer(event, template, currentCustomer)

    "keyup input[name='searchFilter']": (event, template) ->
      staffSearchByInput(event, template, Template.instance())


staffSearchByInput = (event, template, instance)->
  searchFilter     = instance.searchFilter
  $searchFilter    = template.ui.$searchFilter
  searchFilterText = $searchFilter.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Helpers.deferredAction ->
    if searchFilter.get() isnt searchFilterText
      searchFilter.set(searchFilterText)
  , "staffManagementSearchPeople"
  , 100

selectCustomer = (event, template, staff)->
  if userId = Meteor.userId()
    Meteor.users.update(userId, {$set: {'sessions.currentStaff': staff._id}})