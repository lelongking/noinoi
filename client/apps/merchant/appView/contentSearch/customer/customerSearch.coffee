Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineHyper 'customerSearch',
  created: ->
    console.log 'created customerSearch'
    self = this
    self.currentCustomer = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if customerId = Session.get('mySession')?.currentCustomer
        self.currentCustomer.set(Schema.customers.findOne(customerId))

  rendered: ->

  helpers:
    currentCustomer: ->
      Template.instance().currentCustomer.get()

    activeClass: ->
      if @_id is Template.instance().currentCustomer.get()?._id then 'active' else ''


    customerGroupLists: ->
      merchantId = Merchant.getId()
      customerGroups = Schema.customerGroups.find({merchant: merchantId}, {sort: {nameSearch: 1}}).map(
        (customerGroup) ->
          customerGroup.customerListSearched = []
          customerGroup.hasCustomerList = -> customerGroup.customerListSearched.length > 0
          customerGroup
      )

      selector = {};
      if searchText = Template.instance().searchFilter.get()
        regExp = Helpers.BuildRegExp(searchText);
        selector = {$or: [{customerCode: regExp, merchant: merchantId}, {nameSearch: regExp, merchant: merchantId}]}

      if Session.get('myProfile')?.roles is 'seller'
        addCustomerIds = {$in: Session.get('myProfile').customers}
        if(searchText)
          selector.$or[0]._id = addCustomerIds
          selector.$or[1]._id = addCustomerIds
        else
          selector._id = addCustomerIds
      scope.customerLists = []
      Schema.customers.find(selector, {sort: {firstName:1 ,nameSearch: 1}}).forEach(
        (customer) ->
          if customerGroup = _.findWhere(customerGroups, {_id: customer.customerOfGroup ? customer.group})
            customerGroup.customerListSearched.push(customer)
            scope.customerLists.push(customer)
      )
      customerGroups

  events:
    "click .create-new-customer": (event, template) ->
      FlowRouter.go('newCustomer')

    "click .caption.inner.toCustomerGroup": (event, template) ->
      FlowRouter.go('customerGroup')

    "click .list .doc-item": (event, template) ->
      selectCustomer(event, template, @)


#
#    "keyup input[name='searchFilter']": (event, template) ->
#      searchCustomerOrCreateCustomer(event, template, Template.instance())
#
#    "click .createCustomerBtn": (event, template) ->
#      createNewCustomer(event, template, Template.instance())






searchCustomerOrCreateCustomer = (event, template, instance)->
  Helpers.deferredAction ()->
    searchFilter = template.ui.$searchFilter.val()
    instance.searchFilter.set(searchFilter)

    if event.which is 17 then console.log 'up'
#    else if event.which is 38 then scope.CustomerSearchFindPreviousCustomer(customerSearch)
#    else if event.which is 40 then scope.CustomerSearchFindNextCustomer(customerSearch)
    else
      if true #User.hasManagerRoles()
        scope.createNewCustomer(template, searchFilter) if event.which is 13
        setTimeout (-> scope.customerManagementCreationMode(searchFilter.trim()); return), 300
      else
        Session.set("customerManagementCreationMode", false)

  , "customerManagementSearchPeople"
  , 200

selectCustomer = (event, template, customer)->
  if userId = Meteor.userId()
#    Wings.SubsManager.subscribe('getCustomerId', customer._id)
    Meteor.users.update(userId, {$set: {'sessions.currentCustomer': customer._id}})
    Template.instance().currentCustomer.set(customer)
    Session.set('customerManagementIsShowCustomerDetail', false)


createNewCustomer = (event, template, instance)->
  if User.hasManagerRoles()
    fullText       = instance.searchFilter.get()
    customerSearch = Helpers.Searchify(fullText)
    scope.createNewCustomer(template, customerSearch)
    CustomerSearch.search customerSearch