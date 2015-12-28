Enums = Apps.Merchant.Enums

#------------ Models Order ------------
simpleSchema.seasons = new SimpleSchema
  merchantId  : simpleSchema.DefaultMerchant
  isUsed      : type: Boolean , defaultValue: false
  name        : type: String  , optional: true
  description : type: String  , optional: true
  startDate   : type: Date    , optional: true
  endDate     : type: Date    , optional: true

  allowDelete : simpleSchema.DefaultBoolean()
  creator     : simpleSchema.DefaultCreator('creator')
  version     : { type: simpleSchema.Version }


Schema.add 'seasons', "Season", class Season
  @transform: (doc) ->
