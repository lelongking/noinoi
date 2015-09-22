Template.registerHelper 'me', -> Meteor.user()
Template.registerHelper 'Session', (source) -> Session.get(source)
Template.registerHelper 'reactiveVar', (source) -> source?.get()
Template.registerHelper 'routerParamEqual', (source, target) -> Router.current().params[source] is target
Template.registerHelper 'routerParamEmpty', (source) -> !Router.current().params[source]

Template.registerHelper 'isEmptyCollection', (collection) -> return collection.count() is 0
Template.registerHelper 'nodeDetails', -> Document.ApiNode.findOne(@toString())
Template.registerHelper 'nodeActiveClass', -> if @._id is Session.get("currentApiNode")?._id then 'active' else ''
Template.registerHelper 'renderNodeLeaves', -> !Session.get("apiTreeCollapse") and @._id is Session.get("currentApiNode")?._id and Document.ApiMachineLeaf.find({parent: Session.get('currentApiNode')?._id}).count() > 0
Template.registerHelper 'renderNodeChilds', -> @parent != undefined or (!Session.get("apiTreeCollapse") and Session.get('currentApiRoot')?._id is @_id and @childNodes)

Template.registerHelper 'machineMethods', -> Document.ApiMachineLeaf.find {parent: Session.get('currentApiNode')?._id, leafType: Model.Api.nodeTypes.method}
Template.registerHelper 'machineMembers', -> Document.ApiMachineLeaf.find {parent: Session.get('currentApiNode')?._id, leafType: Model.Api.nodeTypes.property}
Template.registerHelper 'brackets', (source) -> "{#{source}}"

Template.registerHelper 'normalHour', (source) -> moment(source).format('h:mm a')
Template.registerHelper 'shortHour', (source) -> moment(source).format('h:mm')

Template.registerHelper 'registeredModals', -> Wings.Component.modals
Template.registerHelper 'currentActiveModal', -> Session.get("currentActiveModal")