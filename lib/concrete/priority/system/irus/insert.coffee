Module 'Wings.IRUS',
  insert: (collection, model, validator = {}, extraChecks) ->
    isValidModel = Wings.IRUS.validate(model, validator)
    return {valid: false, error: isValidModel.error} unless isValidModel.valid

    model.createAt = new Date() if !validator.timestamp?.required and !model.createAt
    model.creator = Meteor.userId() if !model.creator

    resultId = collection.insert(model)
    if resultId then {valid: true, result: resultId} else {valid: false, error: 'insert fail.'}