#Enums = Apps.Merchant.Enums
#scope = logics.customerManagement
#
#Wings.defineHyper 'orderDeliverySearch',
#  created: ->
#    console.log 'created customerSearch'
#    self = this
#    self.currentCustomer = new ReactiveVar()
#    self.searchFilter = new ReactiveVar('')
#    self.autorun ()->
#      if customerId = Session.get('mySession')?.currentCustomer
#        self.currentCustomer.set(Schema.customers.findOne(customerId))
#
#  rendered: ->
#
#  helpers:
#    currentCustomer: ->
#      Template.instance().currentCustomer.get()
#
#    activeClass: ->
#      if @_id is Template.instance().currentCustomer.get()?._id then 'active' else ''
#
#
#    customerGroupLists: ->
#      merchantId = Merchant.getId()
#      customerGroups = Schema.customerGroups.find({merchant: merchantId}, {sort: {nameSearch: 1}}).map(
#        (customerGroup) ->
#          customerGroup.customerListSearched = []
#          customerGroup.hasCustomerList = -> customerGroup.customerListSearched.length > 0
#          customerGroup
#      )
#
#      selector = {merchant: merchantId ? Merchant.getId()};
#      if searchText = Template.instance().searchFilter.get()
#        regExp = Helpers.BuildRegExp(searchText);
#        selector = {$or: [{customerCode: regExp, merchant: merchantId}, {nameSearch: regExp, merchant: merchantId}]}
#
#      if Session.get('myProfile')?.roles is 'seller'
#        addCustomerIds = {$in: Session.get('myProfile').customers}
#        if(searchText)
#          selector.$or[0]._id = addCustomerIds
#          selector.$or[1]._id = addCustomerIds
#        else
#          selector._id = addCustomerIds
#      scope.customerLists = []
#      Schema.customers.find(selector, {sort: {firstName:1 ,nameSearch: 1}}).forEach(
#        (customer) ->
#          if customerGroup = _.findWhere(customerGroups, {_id: customer.customerOfGroup ? customer.group})
#            customerGroup.customerListSearched.push(customer)
#            scope.customerLists.push(customer)
#      )
#      customerGroups
#
#  events:
#    "click .create-new-command": (event, template) ->
#      FlowRouter.go('createCustomer')
#
#    "click .caption.inner.toCustomerGroup": (event, template) ->
#      FlowRouter.go('customerGroup')
#
#    "click .list .doc-item": (event, template) ->
#      selectCustomer(event, template, @)
#
#    "keyup input[name='searchFilter']": (event, template) ->
#      customerSearchByInput(event, template, Template.instance())
#
#
#
#
#customerSearchByInput = (event, template, instance)->
#  searchFilter      = instance.searchFilter
#  $searchFilter     = template.ui.$searchFilter
#  searchFilterText  = $searchFilter.val().replace(/^\s*/, "").replace(/\s*$/, "")
#
#  Helpers.deferredAction ->
#    if searchFilter.get() isnt searchFilterText
#      searchFilter.set(searchFilterText)
#  , "customerManagementSearchPeople"
#  , 100
#
#selectCustomer = (event, template, customer)->
#  if userId = Meteor.userId()
##    Wings.SubsManager.subscribe('getCustomerId', customer._id)
#    Meteor.users.update(userId, {$set: {'sessions.currentCustomer': customer._id}})
#    Session.set('customerManagementIsShowCustomerDetail', false)
#    Session.set('customerManagementIsEditMode', false)
