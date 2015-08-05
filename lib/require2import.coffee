{CompositeDisposable} = require 'atom'

module.exports = Require2import =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that convert require to import
    @subscriptions.add atom.commands.add 'atom-workspace', 'require2import:convert': => @convert()

  deactivate: ->
    @subscriptions.dispose()

  convert: ->
    if editor = atom.workspace.getActiveTextEditor()
      editor.selectLinesContainingCursors()
      if range = editor.getSelectedBufferRange()
        editor.scanInBufferRange(
          /(?:(?:var|const|let)\s+)?(\{?[\w,\s]+\}?)\s+=\s+require\((?:'|")([\w-\.\/]+)(?:'|")\)(;|,)?/,
          range,
          ({match, replace, stop}) ->
            if match.length > 3
              EOL = if match[3] then ';' else ''
              replace("import #{match[1]} from '#{match[2]}'#{EOL}")
            else
              stop()
        )
