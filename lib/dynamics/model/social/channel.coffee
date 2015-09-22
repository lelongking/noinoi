Wings.Document.register 'channels', 'Channel', class Channel
  @ChannelTypes:
    public   : 1
    private  : 2
    direct   : 3

  @insert: (name, description = null, channelType = @ChannelTypes.public) ->
    newChannel = { creator: Meteor.userId(), channelType: channelType, name: name }
    newChannel.description = description if description
    newChannel.slug = Wings.Helpers.Slugify(name)

    Wings.IRUS.insert(Document.Channel, newChannel, {})

  @Initialize: ->
    @insert("tổng quát", "nơi trao đổi mọi thứ, chung chung.")

  constructor : (doc) -> @[key] = value for key, value of doc