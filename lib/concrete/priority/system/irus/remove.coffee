Module 'Wings.IRUS',
  remove: (collection, id, extraChecks) ->
    result = collection.remove id
    if result then {valid: true} else {valid: false, error: 'remove fail.'}