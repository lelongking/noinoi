Enums = Apps.Merchant.Enums
scope = logics.customerManagement

scope.CustomerSearchFindPreviousCustomer = (customerSearch) ->
  if previousRow = scope.customerLists.getPreviousBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': previousRow._id}})


scope.CustomerSearchFindNextCustomer = (customerSearch) ->
  if nextRow = scope.customerLists.getNextBy('_id', Session.get('mySession').currentCustomer)
    Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': nextRow._id}})


scope.customerManagementCreationMode = (textSearch = '')->
  if textSearch.length > 0
    if scope.customerLists.length is 0
      nameIsExisted = true
    else
      nameIsExisted = scope.customerLists[0].name.toLowerCase() isnt textSearch.toLowerCase()
    console.log nameIsExisted
  Session.set("customerManagementCreationMode", nameIsExisted)


scope.createNewCustomer = (template, customerSearch) ->
  newCustomer = Customer.splitName(customerSearch)

  if Customer.nameIsExisted(newCustomer.name, Session.get("myProfile").merchant)
    template.ui.$searchFilter.notify("Khách hàng đã tồn tại.", {position: "bottom"})
  else
    newCustomerId = Schema.customers.insert newCustomer
    if Match.test(newCustomerId, String)
      CustomerGroup.addCustomer(newCustomerId)
      Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentCustomer': newCustomerId}})


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


#---------------------------------------------------------------------------------------------------------------------
Wings.defineHyper 'customerManagementCustomerSearch',
  created: ->
    self = this
    self.searchFilter = new ReactiveVar('')
#    Wings.SubsManager.subscribe('getCustomerLists')

  rendered: ->


  helpers:
    activeClass: -> if Template.parentData()?._id is Template.currentData()?._id then 'active' else ''
    customerListFilters: -> getCustomerLists(Template.instance())


  events:
    "keyup input[name='searchFilter']": (event, template) ->
      searchCustomerOrCreateCustomer(event, template, Template.instance())

    "click .createCustomerBtn": (event, template) ->
      createNewCustomer(event, template, Template.instance())

    "click .list .doc-item": (event, template) ->
      selectCustomer(event, template, @)
