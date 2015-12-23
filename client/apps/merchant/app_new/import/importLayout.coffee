scope = logics.import

Wings.defineApp 'importLayout',
  created: ->
    self = this
    self.currentImport = new ReactiveVar({})
    self.autorun ()->
      if Session.get('mySession')
        scope.currentImport = Schema.imports.findOne Session.get('mySession').currentImport
        self.currentImport.set(scope.currentImport)
        Session.set 'currentImport', scope.currentImport

      newProviderId = Session.get('currentImport')?.provider
      oldProviderId = Session.get('currentProvider')?._id
      if newProviderId
        Session.set('currentProvider', Schema.providers.findOne newProviderId) if !oldProviderId or oldProviderId isnt newProviderId
      else
        Session.set 'currentProvider'

    UnitProductSearch.search('')

  rendered: -> scope.templateInstance = @

  helpers:
    currentImport         : -> Template.instance().currentImport.get()
    tabOptions            : -> scope.tabOptions
    providerSelectOptions : -> scope.providerSelectOptions
    depositOptions        : -> scope.depositOptions
    discountOptions       : -> scope.discountOptions
    debtDateOptions       : -> scope.debtDateOptions

  events:
    "click .print-command": -> window.print()

    'click .importSubmit': (event, template)->
      if currentImport = Session.get('currentImport')
        importLists = Import.findNotSubmitted().fetch()
        if nextRow = importLists.getNextBy("_id", currentImport._id)
          Import.setSession(nextRow._id)
        else if previousRow = importLists.getPreviousBy("_id", currentImport._id)
          Import.setSession(previousRow._id)
        else
          Import.setSession(Import.insert())

        scope.currentImport.importSubmit()

