Wings.defineHyper 'providerSearch',
  created: ->
    self = this
    self.currentProvider = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if currentProviderId = Session.get('mySession')?.currentProvider
        self.currentProvider.set Schema.providers.findOne({_id:currentProviderId})

#        currentProvider = Schema.providers.findOne(currentProviderId)
#        Session.set "providerManagementCurrentProvider", currentProvider
#
#        providerId = if currentProvider?._id then currentProvider._id else false
#        if Session.get("providerManagementProviderId") isnt providerId
#          Session.set "providerManagementProviderId", providerId

    initializeTemplate(self)

  helpers:
    currentProvider: ->
      Template.instance().currentProvider.get()

    activeClass: ->
      if @_id is Template.instance().currentProvider.get()?._id then 'active' else ''


    providerLists: ->
      selector = {}; options  = {sort: {nameSearch: 1}}; searchText = Session.get("providerManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {nameSearch: regExp}
        ]}
      Schema.providers.find(selector, options).fetch()


  events:
    "click .create-new-command": (event, template) ->
      FlowRouter.go('createProvider')

    "keyup input[name='searchFilter']": (event, template) ->
#      scope.searchOrCreateProviderByInput(event, template)


    "click .list .doc-item": (event, template) ->
      Provider.selectProvider(@_id)
      Session.set('providerManagementIsShowProviderDetail', false)


initializeTemplate = (self) ->
  Session.set("providerManagementSearchFilter", '')


getListCustomerGroups = (self) ->
  console.log 'reactive....'
  searchText = Session.get("customerGroupSearchFilter")
  selector = {}; options  = {sort: {isBase: 1, nameSearch: 1}}

  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {nameSearch: regExp}
    ]}

  unless User.hasManagerRoles()
    if searchText
      selector.$or[0].customerLists = {$in: Session.get('myProfile').customers}
    else
      selector.customerLists = {$in: Session.get('myProfile').customers}

  Schema.customerGroups.find(selector, options).fetch()