{CompositeDisposable} = require 'atom'
Shell = require('shell')

module.exports = RustApiHelper =
  subscriptions: null

  activate: (state) ->

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'rust-api-helper:trigger': => @trigger()

  deactivate: ->
    @subscriptions.dispose()

  trigger: ->
    editor = atom.workspace.getActiveTextEditor()
    possibleUseInLine = editor.lineTextForBufferRow(editor.getLastCursor().getBeginningOfCurrentWordBufferPosition().row ).match(/(std::\S*)[\s;]/)
    if possibleUseInLine
      lesscaca = possibleUseInLine[1].replace(/::/g,"/").replace(/(\w*?)$/, "struct.$1.html")
      Shell.openExternal("http://doc.rust-lang.org/#{lesscaca}")
