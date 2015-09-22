goldenRatio = 1.618

Module 'Wings.Design',
  goldenBaseSize: (fullSize) -> fullSize / goldenRatio
  goldenAddOnSize: (baseSize) -> baseSize / goldenRatio
  goldenFullSize: (baseSize) -> baseSize * goldenRatio
  goldenSplit: (fullSize) ->
    baseSize = @goldenBaseSize(fullSize)
    addOnSize = @goldenAddOnSize(baseSize)
    return { base: baseSize, addOn: addOnSize }