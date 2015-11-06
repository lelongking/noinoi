Module 'Wings.Helper',
  ResetSession: (sessionNameLists = []) ->
    if _.isArray(sessionNameLists)
      Session.set(sessionName) for sessionName in sessionNameLists
    else
      console.log 'SessionLists Not Array'