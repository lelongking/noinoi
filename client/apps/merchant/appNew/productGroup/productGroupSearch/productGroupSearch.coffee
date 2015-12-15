Enums = Apps.Merchant.Enums
scope = logics.productManagement

Wings.defineHyper 'productGroupSearch',
  created: ->
    self = this
    self.searchFilter = new ReactiveVar('')


  helpers:
    activeClass: ->
      if @_id is Session.get('mySession')?.currentProductGroup then 'active' else ''

    listProductGroups: ->
      selector = {}; options  = {sort: {isBase: 1, nameSearch: 1}}
      searchText = Template.instance().searchFilter.get()

      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {nameSearch: regExp}
        ]}

#      unless User.hasManagerRoles()
#        if searchText
#          selector.$or[0].productLists = {$in: Session.get('myProfile').products}
#        else
#          selector.productLists = {$in: Session.get('myProfile').products}

      Schema.productGroups.find(selector, options).fetch()


  events:
    "click .caption.inner.toProduct": (event, template) ->
      FlowRouter.go('product')

    "click .create-new-command": (event, template) ->
      FlowRouter.go('createProductGroup')

    "click .list .doc-item": (event, template) ->
      ProductGroup.setSessionProductGroup(@_id)

    "keyup input[name='searchFilter']": (event, template) ->
      productGroupSearchByInput(event, template)



productGroupSearchByInput = (event, template) ->
  searchFilter      = Template.instance().searchFilter
  $searchFilter     = template.ui.$searchFilter
  searchFilterText  = $searchFilter.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Helpers.deferredAction ->
    if searchFilter.get() isnt searchFilterText
      searchFilter.set(searchFilterText)
  , "productGroupSearch"
  , 50

