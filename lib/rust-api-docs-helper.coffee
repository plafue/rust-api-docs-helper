{CompositeDisposable} = require 'atom'
Shell = require 'shell'
CratesRegex = require './crates-regex'

module.exports = RustApiDocsHelper =
  subscriptions: null
  cache: {}

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'rust-api-docs-helper:trigger': => @trigger()

  deactivate: -> @subscriptions.dispose()

  trigger: ->
    possibleImportInLine = @searchForPossibleImportLine()
    if possibleImportInLine
      path = @transformImportToPath(possibleImportInLine)
      if path in Object.keys @cache
        Shell.openExternal(@cache[path])
      else
        @searchMathingDocs(path)

  searchForPossibleImportLine: () ->
    editor = atom.workspace.getActiveTextEditor()
    currentRow = editor.getLastCursor().getBeginningOfCurrentWordBufferPosition().row
    editor.lineTextForBufferRow(currentRow).match(CratesRegex)

  searchMathingDocs: (path) ->
    for objectType in ['struct','trait','fn']
      @assertPageAvailability(path, "#{objectType}.$1.html")
    @assertModulePageAvailability(path)

  assertModulePageAvailability: (path) -> @assertPageAvailability(path, "$1/index.html")

  assertPageAvailability: (path, resourceEndFormat, callback) ->
    p = path.replace(/(\w*?)$/, resourceEndFormat)
    req = new XMLHttpRequest()
    req.onloadend = @openIfAvailable(path, @cache)
    req.onerror = @logSilently
    req.open("HEAD","http://doc.rust-lang.org/#{p}")
    req.send()

  transformImportToPath: (possibleImportInLine) -> @hacks possibleImportInLine[1].replace(/::/g,"/")

  # Open the docs if the request returned 200
  openIfAvailable: (path, cache) -> (e) ->
    if e.currentTarget.status is 200
      urlFound = e.currentTarget.responseURL
      cache[path] = urlFound
      Shell.openExternal(urlFound)

  # Workarounds for some annoyances
  hacks: (path) -> @removeCurliesAndOther @rustcSerializeHack path

  # rustc-serialize is kind of special
  rustcSerializeHack: (path) -> path.replace("rustc_serialize","rustc-serialize/rustc_serialize")

  # This will result in just loading docs of the first import in a curly braces list
  removeCurliesAndOther: (path) -> path.replace(/\{|\}|,|\s/,"")

  logSilently: (error) -> alert error
