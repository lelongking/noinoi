Wings.defineHyper 'providerSearch',
  created: ->
    self = this
    self.searchFilter = new ReactiveVar('')


  helpers:
    activeClass: ->
      if @_id is Session.get('mySession')?.currentProvider then 'active' else ''

    providerLists: ->
      selector = {merchant: merchantId ? Merchant.getId()}; options  = {sort: {nameSearch: 1}}
      searchText = Template.instance().searchFilter.get()

      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector =
          $and: [
            merchant : merchantId ? Merchant.getId()
          ,
            $or: [{name: regExp}, {nameSearch: regExp}]
          ]
      Schema.providers.find(selector, options).fetch()


  events:


    "click .create-new-command": (event, template) ->
      FlowRouter.go('createProvider')

    "keyup input[name='searchFilter']": (event, template) ->
      providerSearchByInput(event, template)

    "click .list .doc-item": (event, template) ->
      Provider.selectProvider(@_id)



providerSearchByInput = (event, template) ->
  searchFilter      = Template.instance().searchFilter
  $searchFilter     = template.ui.$searchFilter
  searchFilterText  = $searchFilter.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Helpers.deferredAction ->
    searchFilter.set(searchFilterText) if searchFilter.get() isnt searchFilterText
  , "providerSearch"
  , 50