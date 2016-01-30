Enums = Apps.Merchant.Enums
scope = logics.customerManagement

Wings.defineHyper 'interestRateSearchCustomer',
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

    activeClass: (editInterestRateManager = false)->
      if Session.get('editInterestRateManager')
        if editInterestRateManager then 'active' else ''
      else
        if @_id is Template.instance().currentCustomer.get()?._id then 'active' else ''


    customerGroupLists: ->
      merchantId = Merchant.getId()
      customerGroups = Schema.customerGroups.find({merchant: merchantId}, {sort: {nameSearch: 1}}).map(
        (customerGroup) ->
          customerGroup.customerListSearched = []
          customerGroup.hasCustomerList = -> customerGroup.customerListSearched.length > 0
          customerGroup
      )

      selector =
        merchant      : merchantId
        interestAmount: {$gt: 0}

      if searchText = Template.instance().searchFilter.get()
        regExp = Helpers.BuildRegExp(searchText);
        selector =
          $and: [
            merchant : merchantId
            interestAmount: {$gt: 0}
          ,
            $or: [{customerCode: regExp}, {name: regExp}, {nameSearch: regExp}]
          ]

      if Session.get('myProfile')?.roles is 'seller'
        addCustomerIds = {$in: Session.get('myProfile').customers}
        if(searchText)
          selector.$or[0]._id = addCustomerIds
          selector.$or[1]._id = addCustomerIds
        else
          selector._id = addCustomerIds
      scope.customerLists = []
      Schema.customers.find(selector, {sort: {nameSearch: 1}}).forEach(
        (customer) ->
          if customerGroup = _.findWhere(customerGroups, {_id: customer.customerOfGroup ? customer.group})
            customerGroup.customerListSearched.push(customer)
            scope.customerLists.push(customer)
      )
      customerGroups

  events:
    "click .caption.inner.editInterestRate": (event, template) ->
      Session.set('editInterestRateManager', true)
      Session.set('customerManagementIsShowCustomerDetail', false)
      Session.set('customerManagementIsEditMode', false)
      Session.set("customerManagementShowEditCommand", false)

    "click .list .doc-item": (event, template) ->
      selectCustomer(event, template, @)
      Helpers.deferredAction ->
        $(".nano.customerDetail").nanoScroller()
        $(".nano.customerDetail").nanoScroller({ scroll: 'bottom' })
      , "autoScrollerBottom"
      , 500

    "keyup input[name='searchFilter']": (event, template) ->
      customerSearchByInput(event, template, Template.instance())




customerSearchByInput = (event, template, instance)->
  searchFilter      = instance.searchFilter
  $searchFilter     = template.ui.$searchFilter
  searchFilterText  = $searchFilter.val().replace(/^\s*/, "").replace(/\s*$/, "")

  Helpers.deferredAction ->
    if searchFilter.get() isnt searchFilterText
      searchFilter.set(searchFilterText)
  , "customerManagementSearchPeople"
  , 100

selectCustomer = (event, template, customer)->
  if userId = Meteor.userId()
#    Wings.SubsManager.subscribe('getCustomerId', customer._id)
    Meteor.users.update(userId, {$set: {'sessions.currentCustomer': customer._id}})
    Session.set('customerManagementIsShowCustomerDetail', false)
    Session.set('customerManagementIsEditMode', false)
    Session.set("customerManagementShowEditCommand", false)
    Session.set('editInterestRateManager', false)
