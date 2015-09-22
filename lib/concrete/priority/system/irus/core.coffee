Module 'Wings.IRUS',
  validate: (source, validator, isArray = false) ->
    pattern = {}

    for key, obj of validator
      unless key is 'timestamp'
        if obj.optional
          pattern[key] = Match.Optional(obj.type)
        else
          pattern[key] = obj.type

        if isArray
          for item in source
            result = customMetaCheck(item, key, obj)
            return result unless result.valid
        else
          result = customMetaCheck(source, key, obj)
          return result unless result.valid

    return {valid: true} if Meteor.isClient and $.isEmptyObject(pattern)
    result = {valid: Match.test(source, if isArray then [Match.ObjectIncluding(pattern)] else Match.ObjectIncluding(pattern))}
    result.error = "Structure of your data is not valid." if !result.valid
    return result

  generateObj: (option, fields)->
    Obj = {}
    for item in fields
      Obj[item] = option[item] if option[item] or option[item] is "" or option[item] is false or option[item] is 0
    return Obj


#----------------------------------------------------------------------------------------------------
customMetaCheck = (source, key, obj) ->
  if !source[key] and obj.optional
    return {valid: true}
  else if !source[key] and !obj.optional
    return {valid: false, error: obj.optionalError ? "#{key} is required!", field: key}
  else if obj.meta
    if obj.type is String
      for currentMeta in obj.meta
        return {valid: false, error: currentMeta.error, field: key} if currentMeta.max and source[key].length > currentMeta.max
        return {valid: false, error: currentMeta.error, field: key} if currentMeta.min and source[key].length < currentMeta.min
    else if (obj.type is Number or obj.type is Match.Integer)
      for currentMeta in obj.meta
        return {valid: false, error: currentMeta.error, field: key} if (currentMeta.max or currentMeta.max is 0) and source[key] > currentMeta.max
        return {valid: false, error: currentMeta.error, field: key} if (currentMeta.min or currentMeta.min is 0) and source[key] < currentMeta.min

  return {valid: true}