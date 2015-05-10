module.exports = GutterDecorator =
  forLine : (lineNr) -> (url) ->
    editor = atom.workspace.getActiveTextEditor()
    marker = editor.markBufferRange([[lineNr, 0], [lineNr, 0]], invalidate: 'never')
    editor.decorateMarker(marker, type : 'line-number', class : 'import-rust-logo')
