Module 'Convert',
  toNumber: (number)-> parseInt(number)
  toNumberAsb: (number)-> Math.abs(parseInt(number))
  toArray: (string)-> if typeof string is "string" then [string] else if Array.isArray(string) then string