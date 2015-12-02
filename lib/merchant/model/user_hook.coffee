#Meteor.users.before.insert (userId, user) ->
#  if userId
#  else
##    user.allowDelete = false
#
#
#
#Meteor.users.after.insert (userId, user) ->
#  if userId
#  else
##    merchantId = Schema.merchants.insert({owner: userId, creator: userId, name: companyName})