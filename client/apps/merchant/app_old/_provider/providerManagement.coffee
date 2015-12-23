Enums = Apps.Merchant.Enums
scope = logics.providerManagement

Wings.defineApp 'providerManagement',
  created: ->
    self = this
    self.autorun ()->
      if currentProviderId = Session.get('mySession').currentProvider
        scope.currentProvider = Schema.providers.findOne(currentProviderId)
        Session.set "providerManagementCurrentProvider", scope.currentProvider

        providerId = if scope.currentProvider?._id then scope.currentProvider._id else false
        if Session.get("providerManagementProviderId") isnt providerId
          Session.set "providerManagementProviderId", providerId

    Session.set("providerManagementSearchFilter", "")

  helpers:
    providerLists: ->
      selector = {}; options  = {sort: {nameSearch: 1}}; searchText = Session.get("providerManagementSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {nameSearch: regExp}
        ]}
      scope.providerLists = Schema.providers.find(selector, options).fetch()
      scope.providerLists

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      scope.searchOrCreateProviderByInput(event, template)

    "click .createProviderBtn": (event, template) ->
      scope.createProviderByBtn(event, template)

    "click .list .doc-item": (event, template) ->
      Provider.selectProvider(@_id)
      Session.set('providerManagementIsShowProviderDetail', false)
