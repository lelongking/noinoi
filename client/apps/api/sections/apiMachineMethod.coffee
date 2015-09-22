Wings.defineHyper 'apiMachineMethod',
  helpers:
    currentCollection: -> Document.ApiMachineLeaf
    paramCommas: ->
      result = ''; return result unless @params
      result += "#{param.name}, " for param in @params
      result.substring(0, result.length - 2)

  events:
    "keyup [name='insertParamInput']": (event, template) ->
      if event.which is 13
        paramString = template.ui.$insertParamInput.val()
        return if paramString.trim() is ''

        Model.Api.Leaf.insertParams(@_id, paramString)
        template.ui.$insertParamInput.val('')
      else if event.which is 27
        template.ui.$insertParamInput.blur()

    "click .wings-insert": (event, template) ->
      template.ui.$insertParamWrapper.removeClass('hide')
      template.ui.$insertParamCommand.addClass('hide')
      template.ui.$insertParamInput.focus()

    "blur [name=insertParamInput]": (event, template) ->
      template.ui.$insertParamWrapper.addClass('hide')
      template.ui.$insertParamCommand.removeClass('hide')

    "click .remove-command": ->
      Model.Api.Leaf.removeParam(Template.parentData()._id, @name)