CratesRegex             = require './crates-regex'
DocsResolver            = require './docs-resolver'
ImportToPathTransformer = require './import-to-path-transformer'
GutterDecorator         = require './gutter-decorator'

module.exports = RsFileWatcher =
  _self: @
  watch: () -> (event) ->
    if event?.uri?.match(/(\w*)$/)[1] is 'rs'
      imports = {}
      for line, lineNr in event.item.buffer.lines
        possibleMatch = line.match CratesRegex
        if possibleMatch then imports[lineNr] = possibleMatch
      for own lineNr, line of imports
        path = ImportToPathTransformer.transform line
        DocsResolver.resolve path, GutterDecorator.forLine(lineNr)
