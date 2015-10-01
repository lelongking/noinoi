Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineApp 'customerManagement',
  created: ->
    self = this
    self.currentCustomer = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if customerId = Session.get('mySession')?.currentCustomer
#        Wings.SubsManager.subscribe('getCustomerId', customerId)
        self.currentCustomer.set(Schema.customers.findOne(customerId))

  rendered: ->


  helpers:
    currentCustomer: ->
      Template.instance().currentCustomer.get()

    activeClass: ->
      if Template.parentData()?._id is Template.currentData()?._id then 'active' else ''

    customerListFilters: ->
      getCustomerLists(Template.instance())


  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchCustomerOrCreateCustomer(event, template, Template.instance())

    "click .createCustomerBtn": (event, template) ->
      createNewCustomer(event, template, Template.instance())

    "click .list .doc-item": (event, template) ->
      selectCustomer(event, template, @)





searchCustomerOrCreateCustomer = (event, template, instance)->
  Helpers.deferredAction ()->
    searchFilter  = template.ui.$searchFilter.val()
    customerSearch = Helpers.Searchify searchFilter
    instance.searchFilter.set(searchFilter)

    if event.which is 17 then console.log 'up'
    else if event.which is 38 then scope.CustomerSearchFindPreviousCustomer(customerSearch)
    else if event.which is 40 then scope.CustomerSearchFindNextCustomer(customerSearch)
    else
      if User.hasManagerRoles()
        scope.createNewCustomer(template, searchFilter) if event.which is 13
        setTimeout (-> scope.customerManagementCreationMode(searchFilter); return), 300
      else
        Session.set("customerManagementCreationMode", false)

  , "customerManagementSearchPeople"
  , 50


createNewCustomer = (event, template, instance)->
  if User.hasManagerRoles()
    fullText       = instance.searchFilter.get()
    customerSearch = Helpers.Searchify(fullText)
    scope.createNewCustomer(template, customerSearch)
    CustomerSearch.search customerSearch


selectCustomer = (event, template, customer)->
  if userId = Meteor.userId()
#    Wings.SubsManager.subscribe('getCustomerId', customer._id)
    Meteor.users.update(userId, {$set: {'sessions.currentCustomer': customer._id}})
    Session.set('customerManagementIsShowCustomerDetail', false)


getCustomerLists = (intance)->
  selector   = {}
  options    = {sort: {nameSearch: 1}}
  searchText = intance.searchFilter.get()

  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {nameSearch: regExp}
    ]}

  if Session.get('myProfile')?.roles is 'seller'
    if(searchText)
      selector.$or[0]._id = $in: Session.get('myProfile').customers
    else
      selector = {_id: {$in: Session.get('myProfile').customers}}

  scope.customerLists = Schema.customers.find(selector, options).fetch()
  scope.customerLists