{CompositeDisposable} = require 'atom'
Shell = require 'shell'
CratesRegex = require './crates-regex'

module.exports = RustApiDocsHelper =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'rust-api-docs-helper:trigger': => @trigger()

  deactivate: ->
    @subscriptions.dispose()

  trigger: ->
    editor = atom.workspace.getActiveTextEditor()
    possibleImportInLine = editor.lineTextForBufferRow(editor.getLastCursor().getBeginningOfCurrentWordBufferPosition().row ).match(CratesRegex)
    if possibleImportInLine
      path = @transformImportToPath(possibleImportInLine)
      pathAfterHacks = @hacks(path)
      for objectType in ['struct','trait','fn']
        @assertPageAvailability(pathAfterHacks, "#{objectType}.$1.html", @openIfAvailable)
      @assertModulePageAvailability(pathAfterHacks)

  assertModulePageAvailability: (path) ->
    @assertPageAvailability(path, "$1/index.html", @openIfAvailable)

  assertPageAvailability: (path, resourceEndFormat, callback) ->
    p = path.replace(/(\w*?)$/, resourceEndFormat)
    req = new XMLHttpRequest()
    req.onloadend = callback
    req.onerror = @logSilently
    req.open("HEAD","http://doc.rust-lang.org/#{p}")
    req.send()

  transformImportToPath: (possibleImportInLine) -> possibleImportInLine[1].replace(/::/g,"/")

  # Open the docs if the request returned 200
  openIfAvailable: (e) ->
    if e.currentTarget.status is 200 then Shell.openExternal(e.currentTarget.responseURL)

  # Workarounds for some annoyances
  hacks: (path) ->
    @removeCurliesAndOther @rustcSerializeHack path

  # rustc-serialize is kind of special
  rustcSerializeHack: (path) -> path.replace("rustc_serialize","rustc-serialize/rustc_serialize")

  # This will result in just loading docs of the first import in a curly braces list
  removeCurliesAndOther: (path) -> path.replace(/\{|\}|,|\s/,"")

  logSilently: (error) -> alert error
