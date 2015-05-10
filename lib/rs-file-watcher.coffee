CratesRegex             = require './crates-regex'
DocsResolver            = require './docs-resolver'
ImportToPathTransformer = require './import-to-path-transformer'

module.exports = RsFileWatcher =
  watch: (event) ->
    if event?.uri?.match(/(\w*)$/)[1] is 'rs'
      imports = (line.match CratesRegex for line in event.item.buffer.lines when line.match CratesRegex)
      transformed = (ImportToPathTransformer.transform i for i in imports)
      for path in transformed
        DocsResolver.resolve(path, (url) -> console.log "Added doc url to cache: #{url}")
