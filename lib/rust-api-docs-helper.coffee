{CompositeDisposable}   = require 'atom'
CratesRegex             = require './crates-regex'
DocsResolver            = require './docs-resolver'
GutterDecorator         = require './gutter-decorator'
ImportToPathTransformer = require './import-to-path-transformer'
Shell                   = require 'shell'

module.exports = RustApiDocsHelper =
  config:
    useInternalBrowser:
      type:'boolean'
      description: """If set, a URL open request will be sent, that will attempt to open the docs URL within atom,
                      in a panel to the right of the current one.
                      Please note that for this functionality to work properly you will need an extra package
                      like mark-hahn/web-browser.
                      """
      default: false
    enableBackgroundResolving:
      type:'boolean'
      description: """
                      Disabling this will only resolve docs URLs on demand (ie. via hotkey),
                      thus reducing cosiderably the amount of requests done in the background.
                   """
      default: true
    enableVisualHints:
      type:'boolean'
      description: """
                      Enable to show gutter icons on imports for which docs have been found.
                      There is a bug at the moment that causes errors with this function.
                   """
      default: true
    rustReleaseChannel:
      type:'string'
      description: """
                      Identifies which release channel to when providing documentation.
                   """
      default: 'stable'
      enum: ['stable', 'beta', 'nightly']

  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'rust-api-docs-helper:trigger': => @trigger()
    if atom.config.get('rust-api-docs-helper.enableBackgroundResolving')
      atom.workspace.observeTextEditors (editor) ->
        if editor.getPath()?.match(/(\w*)$/)[1] is 'rs'
          editor.addGutter
            name: 'rust-api-docs-helper'
            priority: 2
            visible: atom.config.get('rust-api-docs-helper.enableVisualHints')
          new GutterDecorator editor

  deactivate: -> @subscriptions.dispose()

  trigger: ->
    possibleImportInLine = @searchForPossibleImportLine()
    if possibleImportInLine
      path = ImportToPathTransformer.transform(possibleImportInLine)
      DocsResolver.resolve(path, @openUrlCallback())

  searchForPossibleImportLine: ->
    editor = atom.workspace.getActiveTextEditor()
    currentRow = editor.getLastCursor().getBeginningOfCurrentWordBufferPosition().row
    editor.lineTextForBufferRow(currentRow).match(CratesRegex)

  openUrlCallback: ->
    if atom.config.get('rust-api-docs-helper.useInternalBrowser')
      options =
        searchAllPanes: true
        split : 'right'
      (url) -> atom.workspace.open(url, options)
    else
      Shell.openExternal
