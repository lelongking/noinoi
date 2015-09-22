Template.registerHelper 'applicationCollapseClass', -> if Session.get("kernelAddonVisible") then 'collapse' else 'expand'

Template.registerHelper 'productImageSrc', (imageId) -> Storage.ProductImage.findOne(imageId)?.url()
Template.registerHelper 'userImageSrc', (imageId) -> Storage.UserImage.findOne(imageId)?.url()
Template.registerHelper 'customerImageSrc', (imageId) -> Storage.CustomerImage.findOne(imageId)?.url()

Template.registerHelper 'missingImageClass', (imageId) -> if !imageId then 'missing' else ''
Template.registerHelper 'avatarLetter', (source) -> source?.substr(0, 1).toUpperCase()
Template.registerHelper 'userNameById', (userId) -> Meteor.users.findOne(userId).profile.name
Template.registerHelper 'userAvatarLetterById', (userId) -> Meteor.users.findOne(userId).profile.name.substr(0, 1).toUpperCase()
Template.registerHelper 'userAvatarSrcById', (userId) ->
  imageId = Meteor.users.findOne(userId).profile.image
  Storage.UserImage.findOne(imageId)?.url()

Template.registerHelper 'formatNumber', (source) -> accounting.format(source)

Template.registerHelper 'standardDate', (source) -> moment(source).format("DD/MM/YYYY")


Template.registerHelper 'isRowEditing', -> @_id is Session.get("editingId")

Template.registerHelper 'multipliedPrice', -> @price * @quality

Template.registerHelper 'productInfo', ->
  product = Document.Product.findOne({"units._id": @productUnit})
  return {} if !product
  productUnit = _.findWhere(product.units, {_id: @productUnit})
  product : product
  unit    : productUnit

#SEARCHES-----------------------------------------------------
Template.registerHelper 'productSearches', ->
#  Document.Product.find()
  ProductSearch.getData
    transform : (matchText, regExp) -> matchText.replace(regExp, "<b>$&</b>")
    sort      : {isoScore: -1}
