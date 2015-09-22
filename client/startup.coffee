Meteor.startup ->
  moment.locale('vi')
  Sounds.setup ["incoming.mp3", "tieungao.mp3"]
