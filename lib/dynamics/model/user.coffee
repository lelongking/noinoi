cloneName =
  type: String
  autoValue: ->
    return if !@isInsert
    return @field('username').value

userProfile = new SimpleSchema
  name:
    type: String

  gender:
    type: String
    allowedValues: ['Male', 'Female']
    optional: true

  image:
    type: String
    optional: true

  description:
    type: String
    optional: true

Meteor.users.attachSchema new SimpleSchema
  username:
    type: String
    regEx: /^[a-z0-9A-Z_]{3,15}$/
    optional: true

  emails:
    type: [Object]
    optional: true

  "emails.$.address":
    type: String
    regEx: SimpleSchema.RegEx.Email

  "emails.$.verified":
    type: Boolean

  services:
    type: Object
    optional: true
    blackbox: true

  status:
    type: Object
    optional: true
    blackbox: true

  profile:
    type: userProfile
    optional: true

  "profile.name": cloneName

  creator   : Schema.creator
  slug      : Schema.slugify('User', 'username')

  createdAt:
    type: Date

Document.User = Meteor.users