scope = logics.customerGroup

Wings.defineApp 'customerGroup',
  created: ->
    self = this
    self.autorun ()->

    Session.set("customerGroupSearchFilter", "")
    Session.set("customerGroupCreationMode", false)
#    self = this
#    self.autorun() ->
#      if currentCustomerGroupId = Session.get('mySession').currentCustomerGroup
#        customerGroup = Schema.customerGroups.findOne({_id: currentCustomerGroupId})
#        customerGroup = Schema.customerGroups.findOne({isBase: true, merchant: Merchant.getId()}) unless customerGroup
#        if customerGroup
#          customerGroup.customerCount = if customerGroup.customers then customerGroup.customers.length else 0
#          scope.currentCustomerGroup = customerGroup
#          Session.set "currentCustomerGroup", scope.currentCustomerGroup
#          Session.set "customerSelectLists", Session.get('mySession').customerSelected?[Session.get('currentCustomerGroup')._id] ? []
#          $(".changeCustomer").select2("readonly", Session.get("customerSelectLists").length is 0)

  helpers:
    customerGroupLists: ->
      console.log 'reactive....'
      selector = {}; options  = {sort: {isBase: 1, nameSearch: 1}}; searchText = Session.get("customerGroupSearchFilter")
      if(searchText)
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [
          {nameSearch: regExp}
        ]}

      unless User.hasManagerRoles()
        if searchText
          selector.$or[0].customers = {$in: Session.get('myProfile').customers}
        else
          selector.customers = {$in: Session.get('myProfile').customers}

      scope.customerGroupLists = Schema.customerGroups.find(selector, options).fetch()
      scope.customerGroupLists

  events:
    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        Session.set("customerGroupSearchFilter", searchFilter)

        if event.which is 17 then console.log 'up'
        else if event.which is 27 then scope.resetSearchFilter(template)
        else if event.which is 38 then scope.searchFindPreviousCustomerGroup()
        else if event.which is 40 then scope.searchFindNextCustomerGroup()
        else
          if User.hasManagerRoles()
            nameIsExisted = CustomerGroup.nameIsExisted(Session.get("customerGroupSearchFilter"), Session.get("myProfile").merchant)
            Session.set("customerGroupCreationMode", !nameIsExisted)
            scope.createNewCustomerGroup(template) if event.which is 13
          else
            Session.set("customerGroupCreationMode", false)
      , "customerGroupSearchPeople"
      , 50

    "click .createCustomerGroupBtn": (event, template) -> scope.createNewCustomerGroup(template) if User.hasManagerRoles()
    "click .list .doc-item": (event, template) -> CustomerGroup.setSessionCustomerGroup(@_id)