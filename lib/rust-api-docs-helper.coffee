{CompositeDisposable}   = require 'atom'
CratesRegex             = require './crates-regex'
DocsResolver            = require './docs-resolver'
ImportToPathTransformer = require './import-to-path-transformer'
Shell                   = require 'shell'

module.exports = RustApiDocsHelper =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'rust-api-docs-helper:trigger': => @trigger()

  deactivate: -> @subscriptions.dispose()

  trigger: ->
    possibleImportInLine = @searchForPossibleImportLine()
    if possibleImportInLine
      path = ImportToPathTransformer.transform(possibleImportInLine)
      DocsResolver.resolve(path, Shell.openExternal)

  searchForPossibleImportLine: ->
    editor = atom.workspace.getActiveTextEditor()
    currentRow = editor.getLastCursor().getBeginningOfCurrentWordBufferPosition().row
    editor.lineTextForBufferRow(currentRow).match(CratesRegex)
