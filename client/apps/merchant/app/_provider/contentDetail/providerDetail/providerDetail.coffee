Wings.defineHyper 'providerDetail',
  created: ->
    self = this
    self.currentProvider = new ReactiveVar()
    self.searchFilter = new ReactiveVar('')
    self.autorun ()->
      if currentProviderId = Session.get('mySession')?.currentProvider
        self.currentProvider.set Schema.providers.findOne({_id:currentProviderId})


  rendered: ->

  helpers:
    currentProvider: -> Template.instance().currentProvider.get()

  events:
    "keyup input[name='searchFilter']": (event, template) ->