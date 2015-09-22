Model.Api = {}

Model.Api.nodeTypes =
  property: 1
  method  : 2
  example : 3

Model.Api.isValidNode = (nodeObj) ->
  if Match.test(nodeObj.name, String) and nodeObj.name.length < 1
    return { valid: false, message: "invalid node name!" }

#  if Meteor.isServer
#    return { valid: false } if Document.ApiNode.findOne({name: nodeObj.name})

  return { valid: true }

Model.Api.insertNode = (name, parentId) ->
  newChild = {name: name}
  newChild.parent = parentId if parentId

  validation = Model.Api.isValidNode(newChild)
  if !validation.valid
    console.log validation.message
    return

  childId = Document.ApiNode.insert(newChild)
  Document.ApiNode.update(parentId, {$push: {childNodes: childId}}) if parentId

Model.Api.removeNode = (nodeId) -> Document.ApiNode.remove(nodeId)