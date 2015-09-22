Meteor.methods
  sendMessage: (parent, message, messageType) ->
    newMessage = { creator: @userId, parent: parent, message: message, messageType: messageType}

    if latestMessage = Document.Message.findOne({parent: parent}, {sort: {'version.createdAt': -1}})
      dateDiffInMinute = Math.round((((new Date() - latestMessage.version.createdAt) % 86400000) % 3600000) / 60000)
      newMessage.separator = latestMessage.creator isnt @userId or dateDiffInMinute > 6

    Document.Message.insert newMessage