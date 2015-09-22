Wings.defineWidget 'message',
  helpers:
    messageCreator: -> Meteor.users.findOne(@creator)
    avatarImgSrc: -> Storage.UserImage.findOne(Meteor.users.findOne(@creator)?.profile.image)?.url()

  rendered: ->
    window.$kernelMessenger?.nanoScroller()
    window.$kernelMessenger?.nanoScroller({ scroll: 'bottom' }) unless window.manualScrollMessenger