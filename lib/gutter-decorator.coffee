{CompositeDisposable}   = require 'atom'
CratesRegex             = require './crates-regex'
DocsResolver            = require './docs-resolver'
ImportToPathTransformer = require './import-to-path-transformer'

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
    imports = {}
    for line, lineNr in @editor.buffer.lines
      possibleMatch = line.match CratesRegex
      if possibleMatch then imports[lineNr] = possibleMatch
    for own lineNr, line of imports
      path = ImportToPathTransformer.transform line
      DocsResolver.resolve path, @decorateLine(lineNr)

  decorateLine : (lineNr) => (url) =>
    if atom.config.get('rust-api-docs-helper.enableVisualHints')
      marker = @editor.markBufferRange([[lineNr, 0], [lineNr, 0]], invalidate: 'never')
      @editor.decorateMarker(marker, type : 'line-number', class : 'import-rust-logo')
      @markers.push(marker)

  removeDecorations: ->
    marker.destroy() for marker in @markers
    @markers = []
