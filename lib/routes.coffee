Router.configure
  layoutTemplate: 'ApplicationLayout'
  onBeforeAction: ->
    Router.go 'welcome' unless Meteor.userId()
    @next()

currentDocInstance = {}

Router.route '/welcome',
  name: 'welcome'
  layoutTemplate: 'WelcomeLayout'
  onBeforeAction: ->
    Router.go 'home', {slug: 'important', sub: 'product'} if Meteor.userId()
    @next()

globalSub = new SubsManager()
Router.route '/:slug?/:sub?/:subslug?/:action?',
  name: 'home'
  template: 'home'
#  waitOn: ->
#    if Wings.Router.isValid(@)
#      if @params.subslug
#        Meteor.subscribe("sluggedDocument", @params.sub.toCapitalize(), @params.subslug)
#      else
#        Meteor.subscribe("topDocuments", @params.sub.toCapitalize())
  onBeforeAction: ->
    if Wings.Router.isValid(@)
      Meteor.subscribe("topDocuments", @params.sub.toCapitalize())
      Meteor.subscribe(@params.sub, @params.subslug) if @params.subslug
      Meteor.subscribe("sluggedDocument", @params.sub.toCapitalize(), @params.subslug) if @params.subslug
    Wings.Router.renderApplication(@)
    @next()

  data: ->
    channel = Wings.Router.findChannel(@params.slug)
    globalSub.subscribe("channelMessages", channel.instance._id, 0, channel.isDirect) if channel.instance
    Session.set "currentChannel", channel.instance
    Session.set "kernelAddonVisible", !!@params.sub
    Session.set "currentAddon", @params.sub
    Session.set "currentAppColor", _(navigationMenus).findWhere({app: @params.sub})?.color

    predicate = if channel.isDirect
      {$or: [{ parent: channel.instance?._id, creator: Meteor.userId() }, { parent: Meteor.userId(), creator: channel.instance?._id }]}
    else {parent: channel.instance?._id}

    result =
      messages: Document.Message.find(predicate, {sort: {'version.createdAt': 1}})
      slug    : @params.slug
      sub     : @params.sub
      subslug : @params.subslug

    filter = {}
    filter = {creator: {$exists: true}} if @params.sub is 'user'

    if Wings.Router.isValid(@)
      result.documents = Document[@params.sub.toCapitalize()].find(filter)
      result.instance = Document[@params.sub.toCapitalize()].findOne({slug: @params.subslug}) if @params.subslug



    result

Module "Wings",
  go: (sub, subslug, action) ->
    return if !slug = Router.current().params.slug ? null
    Router.go 'home', {slug: slug, sub: sub, subslug: subslug, action: action}
