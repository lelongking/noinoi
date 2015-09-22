Wings.Document.register 'messages', 'Message', class Message
  @MessageTypes:
    direct  : 1
    channel : 2
    group   : 3

  constructor: (doc) -> @[key] = value for key, value of doc

Document.Message.attachSchema new SimpleSchema
  creator:
    type: String

  parent:
    type: String

  messageType:
    type: Number

  message:
    type: String

  separator:
    type: Boolean
    defaultValue: true

  version: { type: Schema.version }