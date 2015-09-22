randomBarcode = (prefix="0", length=10)->
  prefix += Math.floor(Math.random() * 10) for i in [0...length]
  prefix

Module "Schema",
#  Essential: new SimpleSchema
#    creator: { type: Schema.creator }
#    version: { type: Schema.version }

  defaultCreatedAt:
    type: Date
    autoValue: ->
      return new Date unless @isSet
      return

  defaultBoolean: (value = false) ->
    type: Boolean
    autoValue: ->
      return value unless @isSet
      return

  defaultNumber: (num = 0)->
    type: Number
    autoValue: ->
      return num unless @isSet
      return

  clone: (field) ->
    type: String
    autoValue: ->
      return @field(field).value if @field(field).isSet

  creator:
    type: String
    autoValue: -> Meteor.userId() if @isInsert and not @isSet

  uniqueId:
    type: String
    autoValue: ->
      return Random.id() unless @isSet
      return

  barcode:
    type: String
    autoValue: ->
      return randomBarcode() unless @isSet
      return

  version: new SimpleSchema
    createdAt:
      type: Date
      autoValue: ->
        if @isInsert
          return new Date
        else if @isUpsert
          return { $setOnInsert: new Date }
        return

    updateAt:
      type: Date
      autoValue: ->
        return new Date() if @isUpdate
        return

      denyInsert: true
      optional: true

  searchSource: (field) ->
    type: String
    autoValue: ->
      return Wings.Helpers.Searchify(@field(field).value) if @field(field).isSet

  slugify: (source, field = 'name') ->
    type: String
    autoValue: ->
      return if !@isInsert or !slugifySource = @field(field)?.value
      slugify = Wings.Helpers.Slugify(slugifySource); affix = 1; tempSlug = slugify
      slugify = tempSlug + ++affix while Document[source].findOne({slug: slugify})
      slugify