scope = logics.productGroup

Wings.defineApp 'productGroups',
  created: ->
    Session.set("productGroupSearchFilter", "")
    Session.set("productGroupCreationMode", false)

    self = this
    self.autorun ()->
      productGroup = Schema.productGroups.findOne(Session.get('mySession').currentProductGroup)
      productGroup = Schema.productGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless productGroup
      if productGroup
        productGroup.productCount = if productGroup.products then productGroup.products.length else 0
        scope.currentProductGroup = productGroup
        Session.set "currentProductGroup", scope.currentProductGroup
        Session.set "productSelectLists", Session.get('mySession').productSelected?[Session.get('currentProductGroup')._id] ? []

  helpers:
    productGroupLists: ->
      console.log 'reactive....'
      selector = {}; options  = {sort: {isBase: 1, nameSearch: 1}}; searchText = Session.get("productGroupSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {name: regExp}
        ]}
      scope.productGroupLists = Schema.productGroups.find(selector, options).fetch()
      scope.productGroupLists

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        Session.set("productGroupSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 27 then scope.resetSearchFilter(template)
        else if event.which is 38 then scope.searchFindPreviousProductGroup()
        else if event.which is 40 then scope.searchFindNextProductGroup()
        else
          if User.hasManagerRoles()
            nameIsExisted = ProductGroup.nameIsExisted(Session.get("productGroupSearchFilter"), Session.get("myProfile").merchant)
            Session.set("productGroupCreationMode", !nameIsExisted)
            scope.createNewProductGroup(template) if event.which is 13
          else
            Session.set("productGroupCreationMode", false)

      , "productGroupSearchPeople"
      , 50

    "click .createProductGroupBtn": (event, template) -> scope.createNewProductGroup(template) if User.hasManagerRoles()
    "click .list .doc-item": (event, template) -> ProductGroup.setSessionProductGroup(@_id)