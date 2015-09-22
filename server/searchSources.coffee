SearchSource.defineSource 'products', (searchText, options) ->
  options = {sort: {isoScore: -1}, limit: 20}
#  predicate = if searchText then {$text: {$search:searchText, $language: 'en'}} else {}
#  Document.Product.find(predicate, options).fetch()
  if searchText
    regExp = buildRegExp(searchText)
    return Document.Product.find({nameSearch: regExp}, options).fetch()
  else
    return Document.Product.find({}, options).fetch()

buildRegExp = (searchText) ->
  parts = searchText.trim().split(/[ \-\:]+/);
  return new RegExp("(" + parts.join('|') + ")", "ig");