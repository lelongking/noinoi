Wings.defineHyper 'providerDetail',
  created: ->
    self = this
    self.currentProvider = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if currentProviderId = Session.get('mySession')?.currentProvider
        currentProvider = Schema.providers.findOne({_id:currentProviderId})
        currentProvider.isShowProviderDetail = false
        currentProvider.isShowEditCommand = false
        currentProvider.isEditMode = false
        self.currentProvider.set currentProvider


  rendered: ->

  helpers:
    currentProvider: -> Template.instance().currentProvider.get()

  events:
    "keyup input[name='searchFilter']": (event, template) ->