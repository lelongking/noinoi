@Sounds =
  load: (sources, soundPath) ->
    for source in sources
      soundInfo = source.split(".")
      return if soundInfo.length isnt 2
      Sounds[soundInfo[0]] = soundManager.createSound
        id: "#{soundInfo[0]}Sound"
        url: "#{soundPath}/#{source}"

  setup: (sounds, swfPath = "/sounds/swf", soundPath = "/sounds") ->
    soundManager.setup
      url: swfPath
      onready: -> Sounds.load(sounds, soundPath)
      ontimeout: -> console.log 'Sound manager error, could not load the library. Check for swf path or sound files.'