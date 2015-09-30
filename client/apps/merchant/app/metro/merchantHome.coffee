totalDecoratorTiles = 6 * 4
Wings.defineApp 'merchantHome',
  created: ->
#    self = this
#    self.ready = new ReactiveVar()
#    self.autorun ()->
#      handle = Wings.SubsManager.subscribe('publishCounts')
#      self.ready.set(handle.ready())

    Session.set('merchantFullSearches', {orders: [], imports: [], products:[], customers: [], providers: []})

  helpers:
#    isReady : -> Template.instance().ready.get()

    isShowSearch: (collectionName)-> @[collectionName].length > 0
    decoratorIterator: ->
      array = []
      array.push i for i in [0...totalDecoratorTiles]
      array

    showMetroBySeller: -> Session.get('myProfile')?.roles is 'seller'
    showMetroByAdmin: -> Session.get('myProfile')?.roles isnt 'seller'
    metroLockerStaff: -> if User.hasAdminRoles() then '' else ' locked'

  events:
    "click [data-app]:not(.locked)": (event, template) -> FlowRouter.go $(event.currentTarget).attr('data-app')

    "click .caption.inner": ->
      if @model is 'orders'
        Meteor.users.update(userId, {$set: {'sessions.currentOrderBill': @_id}}) if userId = Meteor.userId()
        FlowRouter.go('/orderManager')

      else if @model is 'imports'
        Meteor.users.update(userId, {$set: {'sessions.currentProvider': @provider}}) if userId = Meteor.userId()
        FlowRouter.go('/providerManagement')

      else if @model is 'customers'
        Meteor.users.update(userId, {$set: {'sessions.currentCustomer': @_id}}) if userId = Meteor.userId()
        FlowRouter.go('/customer')

      else if @model is 'providers'
        Meteor.users.update(userId, {$set: {'sessions.currentProvider': @_id}}) if userId = Meteor.userId()
        FlowRouter.go('/providerManagement')

      else if @model is 'products'
        Meteor.users.update(Meteor.userId(), {$set: {'sessions.currentProduct': @_id}}) if userId = Meteor.userId()
        FlowRouter.go('/product')

    "keyup input[name='searchFilter']": (event, template) ->
      Helpers.deferredAction ->
        searchFilter  = template.ui.$searchFilter.val()
        customerSearch = Helpers.Searchify searchFilter
        searchData = {orders: [], imports: [], products:[], customers: [], providers: []}
        if customerSearch
          regExp = Helpers.BuildRegExp(customerSearch)
          searchData.orders    = Schema.orders.find({$or: [{orderCode: regExp}]}).fetch()
          searchData.imports   = Schema.imports.find({$or: [{importCode: regExp}]}).fetch()
          searchData.products  = Schema.products.find({$or: [{nameSearch: regExp}]}).fetch()
          searchData.customers = Schema.customers.find({$or: [{nameSearch: regExp}]}).fetch()
          searchData.providers = Schema.providers.find({$or: [{nameSearch: regExp}]}).fetch()
        Session.set('merchantFullSearches', searchData)
      , "fullSearches"
      , 50