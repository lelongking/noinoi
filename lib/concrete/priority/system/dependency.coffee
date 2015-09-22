Wings.dependencies = []

recursiveResolve = (nextDependency, currentDependencies = []) ->
  for dep in nextDependency
    continue if _.findWhere(currentDependencies, dep)
    if Wings.dependencies[dep]
      recursiveResolve(Wings.dependencies[dep], currentDependencies)
    else
      currentDependencies.push(dep)

  currentDependencies

Module 'Wings.Dependency',
  add: (name, deps) -> Wings.dependencies[name] = deps

  resolve: (name) ->
    return if !Wings.dependencies[name]
    dependencies = recursiveResolve(Wings.dependencies[name])

    subscriptions = []
    for dep in dependencies
      if typeof(dep) is 'string'
        subscriptions.push Meteor.subscribe.call(Meteor, dep)
      else if Array.isArray(dep)
        subscriptions.push Meteor.subscribe.apply(Meteor, dep)

    return subscriptions

  list: (dependency = undefined ) ->
    if dependency and Wings.dependencies[dependency]
      console.log recursiveResolve(Wings.dependencies[dependency])
    else
      console.log name, value for name, value of Wings.dependencies when Array.isArray(value)
    return