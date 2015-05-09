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
    possibleImportInLine = editor.lineTextForBufferRow(editor.getLastCursor().getBeginningOfCurrentWordBufferPosition().row ).match(/(std::\S*)[\s;]/)
    if possibleImportInLine
      path = @transformImportToPath(possibleImportInLine)
      for objectType in ['struct','trait','fn']
        @sendRequestForObjectType(path, objectType)

  sendRequestForObjectType: (path, objectType) ->
    p = path.replace(/(\w*?)$/, "#{objectType}.$1.html")
    req = new XMLHttpRequest();
    req.addEventListener("loadend",@handleRequestEnd ,false);
    req.open("HEAD","http://doc.rust-lang.org/#{p}")
    req.send()

  transformImportToPath: (possibleImportInLine) -> possibleImportInLine[1].replace(/::/g,"/")

  handleRequestEnd: (e) ->
    if e.currentTarget.status is 200 then Shell.openExternal(e.currentTarget.responseURL)
