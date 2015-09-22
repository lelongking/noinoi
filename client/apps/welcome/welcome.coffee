colors = [
  '#54c8eb', # light blue
#  '#375673', # med blue
  '#4b97d2', # dark blue
#  '#92cc8f', # light green
#  '#41bb98', # mint green
#  '#c9de83', # yellowish green
#  '#dee569', # yellowisher green
  '#c891c0', # light purple
  '#9464a8', # med purple
  '#7755a1', # dark purple
  '#f069a1', # light pink
  '#f05884', # med pink
  '#e7457b', # dark pink
  '#ffd47e', # peach
  '#f69078'  # salmon
]

errorTranslate = [
  org: "Match failed"
  trans: "thiếu thông tin"
,
  org: "User not found"
  trans: "không tìm thấy tài khoản"
,
  org: "Incorrect password"
  trans: "mật khẩu chưa chính xác"
]

currentIndex = 0
@loginAlertClearTimeOut = null
animateBackgroundColor = ->
  $("body").css("background-color", colors[currentIndex++])
  currentIndex = 0 if currentIndex > colors.length

showAlert = (error, template) ->
  template.ui.$alert.html(error).promise().done ->
    Meteor.clearTimeout(window.loginAlertClearTimeOut)
    if template.ui.$alert.attr('class') is 'animated bounceIn'
      template.ui.$alert.removeClass().addClass('animated shake')
    else
      template.ui.$alert.removeClass().addClass('animated bounceIn')
  window.loginAlertClearTimeOut = Meteor.setTimeout ->
    template.ui.$alert.removeClass().addClass('animated fadeOutLeft')
  , 5000

Wings.defineHyper 'welcome',
  helpers:
    showError: -> Session.get("showLoginError")

  rendered: ->
    welcomeScope = @
    @ui.$user.focus()
    Meteor.setTimeout ->
      animateBackgroundColor()
      welcomeScope.bgInterval = Meteor.setInterval(animateBackgroundColor, 15000)
    , 1000

  destroyed: ->
    Meteor.clearInterval(@bgInterval)
    Session.set("showLoginError")
    $("body").attr("style", "")

  events:
    "click .button.login": (event, template) ->
      username = template.ui.$user.val()
      password = template.ui.$secret.val()

      Meteor.loginWithPassword username, password, (error, result) ->
        if error
          translated = _(errorTranslate).findWhere({org: error.reason})?.trans
          showAlert(translated, template)
        else
          Router.go 'home', {slug: 'important', sub: 'product'}
    "keyup input": (event, template) -> template.find(".button.login").click() if event.which is 13
