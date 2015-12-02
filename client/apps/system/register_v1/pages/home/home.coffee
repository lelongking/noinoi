currentIndex = 0
colors = [
  '#54c8eb', # light blue
  '#4ea9de', # med blue
  '#4b97d2', # dark blue
  '#92cc8f', # light green
  '#41bb98', # mint green
  '#c9de83', # yellowish green
  '#dee569', # yellowisher green
  '#c891c0', # light purple
  '#9464a8', # med purple
  '#7755a1', # dark purple
  '#f069a1', # light pink
  '#f05884', # med pink
  '#e7457b', # dark pink
  '#ffd47e', # peach
  '#f69078'  # salmon
]

registerErrors = [
  incorrectPassword  = { reason: "Incorrect password",  message: "tài khoản tồn tại"}
]

animateBackgroundColor = ->
  $(".animated-bg").css("background-color", colors[currentIndex])
  currentIndex++
  currentIndex = 0 if currentIndex > colors.length

Wings.defineWidget 'home',
  helpers:
    registerValid: ->
      if Session.get('registerAccountValid') == Session.get('registerSecretValid') == 'valid'
        'valid'
      else
        'invalid'
    registerSecretValid: -> Session.get('registerSecretValid')
    termButtonActive: -> if Session.get('topPanelMinimize') then '' else 'reading'

#  created: -> Router.go('/merchant') unless Meteor.userId() is null or (Session.get('autoNatigateDashboardOff'))
  created: ->
    FlowRouter.go('/merchant') if Meteor.userId()

  rendered: ->
    self = @
    Meteor.setTimeout ->
      animateBackgroundColor()
      self.bgInterval = Meteor.setInterval(animateBackgroundColor, 15000)
    , 5000
  destroyed: -> Meteor.clearInterval(@bgInterval)

  events:
    "click #authButton.valid": (event, template) -> logics.homeHeader.login(event, template)
    "click #gotoMerchantButton": -> FlowRouter.go('/merchant')
    "click #logoutButton": -> Wings.logout()
    "keypress .login-field": (event, template) ->
      $(template.find("#authButton")).click() if event.which is 13 and Session.get('loginValid') is 'valid'

    "input .login-field": (event, template) ->
      $login    = $(template.find("#authAlias"))
      $password = $(template.find("#authSecret"))
      if $login.val().length > 0 and $password.val().length > 0
        Session.set('loginValid', 'valid')
      else
        Session.set('loginValid', 'invalid')



    "click #terms": -> Session.set('topPanelMinimize', !Session.get('topPanelMinimize'))
    "click #merchantRegister.valid": (event, template)->
      $companyName    = $(template.find("#companyName"))
      $companyPhone   = $(template.find("#companyPhone"))
      $account        = $(template.find("#account"))
      $secret         = $(template.find("#secret"))

      console.log  $account.val(), $secret.val(), $companyName.val(), $companyPhone.val()
      Meteor.call "registerMerchant", $account.val(), $secret.val(), $companyName.val(), $companyPhone.val(), (error, result) ->
        if error
          console.log error
        else
          Meteor.loginWithPassword $account.val(), $secret.val(), (error, result) ->

    "blur #account": (event, template) ->
      $account = $(template.find("#account"))
      account = $account.val()
      if account.length > 0
        if Wings.Validate.isEmail(account)
          Meteor.loginWithPassword account, '', (error, result) ->
            console.log error, result
            if error?.reason is "Incorrect password"
              $account.notify("tài khoản đã tồn tại", {position: "top"})
              Session.set('registerAccountValid', 'invalid')
            else
              Session.set('registerAccountValid', 'valid')
        else
          $account.notify("email không chính xác", {position: "top"})
      else
        Session.set('registerAccountValid', 'invalid')

    "keyup #secret": (event, template) ->
      $secret  = $(template.find("#secret"))
      $secretConfirm = $(template.find("#secretConfirm"))
      if $secretConfirm.val().length > 0 or $secret.val().length > 0 or $secretConfirm.val() is $secret.val()
        Session.set('registerSecretValid', 'invalid')
      else
        Session.set('registerSecretValid', 'valid')

    "keyup .secret-field": (event, template) ->
      $secret  = $(template.find("#secret"))
      $secretConfirm = $(template.find("#secretConfirm"))
      if $secret.val().length > 0 and  $secretConfirm.val() is $secret.val()
        Session.set('registerSecretValid', 'valid')
      else
        Session.set('registerSecretValid', 'invalid')
