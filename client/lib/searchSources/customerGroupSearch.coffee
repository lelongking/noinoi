@CustomerGroupSearch = new SearchSource 'customerGroups', ['name']

@CustomerGroupSearch.fetchData =(searchText, options, callback) ->
  selector = {merchant: merchantId ? Merchant.getId()}; options = {sort: {isBase: 1, name: 1}, limit: 20}
  if(searchText)
    regExp = Helpers.BuildRegExp(searchText);
    selector = {$or: [
      {name: regExp, merchant: merchantId ? Merchant.getId()}
    ]}
  callback(false, Schema.customerGroups.find(selector, options).fetch())

Template.registerHelper 'customerGroupSearches', ->
  CustomerGroupSearch.getData
#    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {isBase: 1, name: 1}
