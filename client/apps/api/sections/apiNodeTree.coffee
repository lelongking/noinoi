Wings.defineWidget 'apiNodeTree',
  currentNode: -> Session.get('currentApiNode')

  events:
    "click li.api-node": (event, template) ->
      Session.set "currentApiNode", @;
      if !@parent
        if Session.get("currentApiRoot")?._id is @_id
          Session.set("apiTreeCollapse", !Session.get("apiTreeCollapse"))
        else
          Session.set "currentApiRoot", @
      event.stopPropagation()
    "click .remove-node": (event, template) ->
      smartEmptyCurrentSelection(@) if Session.get("currentApiNode")
      Model.Api.removeNode(@_id)

    "keyup input[name='apiFilter']": (event, template) ->
      if event.which is 13
        $target = $(event.currentTarget)
        if (!Session.get("currentApiNode") || event.shiftKey)
          Model.Api.insertNode($target.val())
          $target.val('')
        else
          Model.Api.insertNode($target.val(), Session.get("currentApiNode")._id)
          $target.val('')

#----------------------------------------------
smartEmptyCurrentSelection = (instance) ->
  currentNode = Session.get("currentApiNode")
  loop
    (Session.set "currentApiNode"; console.log "session cleaned"; break) if currentNode._id == instance._id
    break if !currentNode.parent

    currentNode = Document.ApiNode.findOne(currentNode.parent)
    break if !currentNode