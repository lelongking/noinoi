Module 'Wings.IRUS',
  setField: (collection, model, field, value, validator = {}, extraChecks...) ->
    simulate = _(model).clone(); simulate[field] = value
    isValidModel = @validate(simulate, validator)
    return {valid: false, error: isValidModel.error} unless isValidModel.valid
    updateOptions = {}; updateOptions[field] = value
    updateOptions.updateAt = new Date() unless validator.timestamp is false
    collection.update(model._id, {$set: updateOptions})
    return {valid: true}

  update: (collection, id, model, fields = [], validator, extraChecks...) ->
    updateOptions = @generateObj(model, fields)
    isValidModel = @validate(updateOptions, validator)
    return isValidModel unless isValidModel.valid
    updateOptions.updateAt = new Date() unless validator.timestamp is false
    result = collection.update id ? model._id, $set:updateOptions if _.keys(updateOptions).length > 0
    if result then {valid: true} else {valid: false, error: 'update fail.'}
