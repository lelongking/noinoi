Wings.defineHyper 'wingsEditor',
  helpers:
    fieldValue: -> @model?[@field]
    saveRemainingClass: -> if Template.instance().saveRemaining.get() then 'save-remaining' else ''
    activeClass: -> if Template.instance().hasFocus.get() then 'active' else ''

  created: ->
    Template.instance().saveRemaining = new ReactiveVar(false)
    Template.instance().hasFocus = new ReactiveVar(false)
  rendered: -> @ui.$editor.html(@data?.model[@data?.field])

  events:
    "click .button.save": (event, template) ->
      newValue = $(template.find(".wings-editor")).html()
      updatePredicate = {$set: {}}; updatePredicate.$set[@field] = newValue
      templateInstance = Template.instance()
      Document[@model.Document].update @model._id, updatePredicate, (error, result) ->
        if error
          console.log error
        else
          templateInstance.saveRemaining.set(error)

    "input .wings-editor": -> Template.instance().saveRemaining.set(true)
    "focus .wings-editor": -> Template.instance().hasFocus.set(true)
    "blur .wings-editor": -> Template.instance().hasFocus.set(false)