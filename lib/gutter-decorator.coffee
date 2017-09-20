{CompositeDisposable}   = require 'atom'
CratesRegex             = require './crates-regex'
DocsResolver            = require './docs-resolver'
ImportToPathTransformer = require './import-to-path-transformer'
Shell                   = require 'shell'

module.exports = class GutterDecorator
  constructor: (@editor) ->
    @subscriptions = new CompositeDisposable()
    @markers = []

    @subscriptions.add @editor.onDidStopChanging @updateMarkers
    @subscriptions.add @editor.onDidChangePath @updateMarkers
    @subscriptions.add @editor.onDidDestroy =>
      @removeDecorations()
      @subscriptions.dispose()

  updateMarkers: =>
    return if @editor.isDestroyed()
    @removeDecorations()
    if atom.config.get('rust-api-docs-helper.enableVisualHints')
      lines = @editor.getBuffer().getLines()
      for line, lineNr in lines
        possibleMatch = line.match CratesRegex
        if possibleMatch
          path = ImportToPathTransformer.transform possibleMatch
          DocsResolver.resolve path, @decorateLine lineNr

  decorateLine : (lineNr) -> (url) =>
      marker = @editor.markBufferRange([[lineNr, 0], [lineNr, 0]], invalidate: 'never')
      @editor.gutterWithName('rust-api-docs-helper').decorateMarker marker,
        class: 'import-rust-logo'
        item: @createImg(url)
      @markers.push(marker)

  createImg: (url)  ->
    divee = document.createElement 'div'
    divee.addEventListener 'click', () ->
      if atom.config.get('rust-api-docs-helper.useInternalBrowser')
        atom.workspace.open url,
          searchAllPanes: true, split : 'right'
      else
        Shell.openExternal url
    divee


  removeDecorations: ->
    marker.destroy() for marker in @markers
    @markers = []
