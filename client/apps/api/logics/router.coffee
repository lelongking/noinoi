scope = logics.api = {}

Router.route '/api',
  name: 'api'
  onBeforeAction: ->
    if @ready()
      Wings.Router.setup(scope, setups.apiInits, "apiDocumentation")
      @next()
  data: ->
    Wings.Router.setup(scope, setups.apiReactives)
    return {
      apiNodes: Document.ApiNode.find({parent: {$exists: false}}, {sort: {name: 1}})
      apiTechLeaves: Document.ApiMachineLeaf.find({})
      apiBizLeaves: Document.ApiHumanLeaf.find({})
    }