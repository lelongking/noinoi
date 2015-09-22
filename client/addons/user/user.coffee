Wings.defineHyper 'user',
  events:
    "click .doc-item": -> Wings.go('user', @slug)
    "keyup input.insert": (event, template) ->
      if event.which is 13
        $insertField = $(template.find("[name=insertInput]"))
        Meteor.call "createAccount", {username: $insertField.val(), password: "12345"}, (error, result) ->
          (console.log error; return) if error
          newUser = Meteor.users.findOne(result)
          Wings.go 'user', newUser.slug
          $insertField.val('')