module.exports = ImportToPathTransformer =
  transform: (possibleImportInLine) -> @hacks possibleImportInLine[1].replace(/::/g,"/")

  # Workarounds for some annoyances
  hacks: (path) -> @removeCurliesAndOther @rustcSerializeHack path

  # rustc-serialize is kind of special
  rustcSerializeHack: (path) -> path.replace("rustc_serialize","rustc-serialize/rustc_serialize")

  # This will result in just loading docs of the first import in a curly braces list
  removeCurliesAndOther: (path) -> path.replace(/\{|\}|,|\s/,"")
