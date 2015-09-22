#Meteor.publish 'fake', ->
#  self = @
#  setTimeout ->
#    self.ready()
#  , 20000

Meteor.publish null, -> Storage.ProductImage.find({})
Meteor.publish null, -> Storage.UserImage.find({})
Meteor.publish null, -> Storage.CustomerImage.find({})

Meteor.publish null, -> Document.Product.find({})

Meteor.publish "channels", -> Document.Channel.find({})
Meteor.publish "friends",  -> Meteor.users.find({})
Meteor.publish "messages", -> Document.Message.find({})

Meteor.publish "branches", -> Document.Branch.find({})
Meteor.publish "products", -> Document.Product.find({})
Meteor.publish "staffs", -> Document.Message.find({})
Meteor.publish "customers", -> Document.Customer.find({})
Meteor.publish "orders", -> Document.Order.find({})
Meteor.publish "imports", -> Document.Import.find({})

Meteor.publish "topDocuments", (collectionName) ->
  Document[collectionName].find({}, {limit: 20})

Meteor.publish "sluggedDocument", (collectionName, slug) ->
  Document[collectionName].find({slug: slug}, {limit: 1})

Meteor.publish "channelMessages", (channelId, currentCount = 0, isDirect = false) ->
  predicate = if isDirect
    {$or: [{ parent: channelId, creator: @userId }, { parent: @userId, creator: channelId }]}
  else { parent: channelId }

  Document.Message.find predicate, {sort: {'version.createdAt': -1}, skip: currentCount,  limit: 100}