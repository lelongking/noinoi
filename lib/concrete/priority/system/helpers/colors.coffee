colors = ['green', 'light-green', 'yellow', 'orange', 'blue', 'dark-blue', 'lime', 'pink', 'red', 'purple', 'dark',
          'gray', 'magenta', 'teal', 'turquoise', 'green-sea', 'emeral', 'nephritis', 'peter-river', 'belize-hole',
          'amethyst', 'wisteria', 'wet-asphalt', 'midnight-blue', 'sun-flower', 'carrot', 'pumpkin', 'alizarin',
          'pomegranate', 'clouds', 'sky', 'silver', 'concrete', 'asbestos']

generateRandomIndex = -> Math.floor(Math.random() * colors.length)
colorGenerateHistory = []

Module 'Wings.Helper',
  randomColor: ->
    colorGenerateHistory = [] if colorGenerateHistory.length >= colors.length

    while true
      randomIndex = generateRandomIndex()
      colorExisted = _.contains(colorGenerateHistory, randomIndex)
      break unless colorExisted

    colorGenerateHistory.push randomIndex
    colors[randomIndex]