recursiveRemoveChild = (childNodes)->
  Document.ApiNode.find({_id: {$in:childNodes}}).forEach (apiNode) ->
    Document.ApiNode.remove apiNode._id
    Document.ApiHumanLeaf.remove({parent: apiNode._id})
    Document.ApiMachineLeaf.remove({parent: apiNode._id})

    recursiveRemoveChild(apiNode.childNodes) if apiNode.childNodes

Document.ApiNode.after.remove (userId, doc) ->
  Document.ApiNode.update(doc.parent, {$pull: {childNodes: doc._id}}) if doc.parent
  Document.ApiHumanLeaf.remove({parent: doc._id})
  Document.ApiMachineLeaf.remove({parent: doc._id})
  recursiveRemoveChild(doc.childNodes) if doc.childNodes

Document.ApiNode.allow
  insert: (userId, apiNode) -> Model.Api.isValidNode(apiNode).valid
  update: (userId, apiNode, fieldNames, modifier)->
    if _.contains(fieldNames, "childNodes")
      if Document.ApiNode.findOne(modifier.$push.childNodes) then return true else return false
    return true
  remove: (userId, apiNode)-> true