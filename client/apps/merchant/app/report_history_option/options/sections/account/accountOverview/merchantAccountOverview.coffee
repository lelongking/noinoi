syncGenderStatus = (switchery, gender) -> switchery.element.click() if switchery.isChecked() isnt gender

Wings.defineHyper 'merchantAccountOverview',
  helpers:
    profile: -> Session.get("myProfile")
    gender: -> Session.get("merchantAccountOptionsGenderSelection") ? @gender
    showEditCommand: -> Session.get("merchantAccountOptionShowEditCommand")

  rendered: ->
    self = this
    syncGenderStatus(self.switch.gender, Session.get("myProfile")?.gender ? true)
    @datePicker.$dateOfBirth.datepicker('setDate', Session.get('myProfile')?.dateOfBirth)

  events:
    "change [name='gender']": (event, template) ->
      Session.set("merchantAccountOptionsGenderSelection", event.target.checked)
      logics.merchantOptions.checkUpdateAccountOption(template)

    "change [name='dateOfBirth']": (event, template) -> logics.merchantOptions.checkUpdateAccountOption(template)
    "input .accountProfileOption": (event, template) -> logics.merchantOptions.checkUpdateAccountOption(template)
    "keyup .accountProfileOption": (event, template) -> logics.merchantOptions.updateAccountOption(template) if event.which is 13
    "click .syncAccountProfileEdit": (event, template) -> logics.merchantOptions.updateAccountOption(template)