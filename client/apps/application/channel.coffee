Wings.defineHyper 'channel',
  helpers:
    isActiveChannel: -> if Session.get('currentChannel')?._id is @_id then 'active' else ''
    channels: -> Document.Channel.find({channelType: Model.Channel.ChannelTypes.public})
    groups: -> Document.Channel.find({channelType: Model.Channel.ChannelTypes.private})
    friends: -> Meteor.users.find()
    avatarImgSrc: -> Storage.UserImage.findOne(Meteor.user()?.profile.image)?.url()
    onlineClass: -> if @status?.online then 'active' else ''
    myOnlineClass: -> if Meteor.user()?.status?.online then 'active' else ''
    myOnlineStatus: -> if Meteor.user()?.status?.online then 'Online' else 'Offline'

  created: ->
    Meteor.subscribe "friends"
    Meteor.subscribe "channels"

  events:
    "click .channel-item": (event, template) ->
      data = template.data
      homePath = Router.routes['home'].path()
      homePath += if @profile then "@#{@slug}" else @slug
      homePath += "/#{data.sub}" if data.sub
#      homePath += "/#{data.subslug}" if data.sub and data.subslug

      Router.go homePath

    "click .user-configs": (event, template) ->
      Wings.showPopup template.ui.$userConfigMenu, event

    "click .change-avatar": (event, template) -> template.find(".avatar-image-input").click()
    "change .avatar-image-input": (event, template) ->
      files = event.target.files
      if files.length > 0
        Storage.UserImage.insert files[0], (error, fileObj) ->
          if error then console.log 'avatar image upload error', error
          else
            Storage.UserImage.findOne(Meteor.user().profile.image)?.remove()
            Meteor.users.update Meteor.userId(), {$set: {'profile.image': fileObj._id}}

Wings.defineWidget 'userConfigMenu',
  events:
    "click #logout": (event, template)  -> Meteor.logout()
    "click #config": (event, template)  -> openOptionsAt('notificationOptions')
    "click #profile": (event, template) -> openOptionsAt('profileOptions')
    "click #display": (event, template) -> openOptionsAt('displayOptions')

openOptionsAt = (menu) ->
  Session.set("userOptionActiveMenu", menu)
  Wings.showModal 'modalUserOptions'