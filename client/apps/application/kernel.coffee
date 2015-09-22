messengerScrollTopHandler = ->
  channel = Wings.Router.findChannel(Router.current().params.slug)
  subscribedCount = Document.Message.find({parent: channel.instance._id}).count()
  Meteor.subscribe("channelMessages", channel.instance._id, subscribedCount, channel.isDirect)
  window.$kernelMessenger?.nanoScroller({scrollTop: 10})

Wings.defineWidget 'kernel',
  created: ->
    timeStamp = new Date()
    @incomingObserver = Document.Message.find().observeChanges
      added: (id, instance) ->
        if instance.version?.createdAt > timeStamp
#          Sounds.incoming.start()
          senderName = Meteor.users.findOne(instance.creator)?.profile.name
          Wings.notify instance.message,senderName
          console.log 'ping..'

#    @incomingObserver = currentMessages.observeChanges
#      added: (id, instance) ->
#        createjs.Sound.play("incomeMessage") if instance.createAt > timeStamp
#        console.log 'ping..'

  destroyed: ->
    @incomingObserver.stop()

  rendered: ->
    messenger = window.$kernelMessenger = $(@find(".messenger-scroller"))
    messenger.debounce "scrolltop", messengerScrollTopHandler, 100

  events:
    "keyup .messenger-input": (event, template) ->
      if event.which is 13 and currentChannel = Session.get("currentChannel")
        $message = $(event.currentTarget)
#        result = Model.Message.insert(currentChannel._id, $message.val(), currentChannel.channelType)
        channelType = currentChannel.channelType ? Model.Channel.ChannelTypes.direct
        Meteor.call 'sendMessage', currentChannel._id, $message.val(), channelType, (error, result) ->
          if error
            console.log error
          else
            $message.val(''); Sounds.incoming.start()
            window.$kernelMessenger?.nanoScroller({ scroll: 'bottom' })

    "update .messenger-scroller": (event, template, vals) ->
      window.manualScrollMessenger = vals.maximum - vals.position > 40