RailsOpenRspecView = require './rails-open-rspec-view'
{CompositeDisposable} = require 'atom'
{TextEditor} = require 'atom'

fs = require 'fs'
Path = require 'path'

RAILS_ROOT = atom.project.getPaths()[0]

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "rails-open-rspec:open-rspec-file", => @openSpec()

  openSpec: ->
    editor = atom.workspace.getActiveTextEditor()
    currentFilepath = editor.getPath()
    openFilePath = @findFilepath(currentFilepath)
    console.log openFilePath

    return if openFilePath == null

    lines = editor.getBuffer().getLines()
    @openWithWrite(openFilePath, lines)

  findFilepath: (currentFilepath) ->
    relativePath = currentFilepath.substring(RAILS_ROOT.length)

    if @isSpecFile(relativePath)
      openFilePath = relativePath.replace /\_spec\.rb$/, '.rb'
      openFilePath = openFilePath.replace /^\/spec\//, "/app/"
    else
      openFilePath = relativePath.replace /\.rb$/, '_spec.rb'
      openFilePath = openFilePath.replace /^\/app\//, "/spec/"

    if relativePath == openFilePath
      null
    else
      Path.join RAILS_ROOT, openFilePath

  isSpecFile: (path) ->
    /_spec\.rb/.test(path)

  isSinglePane: ->
    atom.workspace.getPanes().length == 1

  getMethodNames: (lines) ->
    defLines = lines.map (line) ->
      arr = line.match(/^\s*def ([^\(]*)/)
      arr[1] if arr

    defLines.filter (line) -> line?

  openWithWrite: (openFilePath, lines) ->
    openOptions = {}
    if @isSinglePane()
      openOptions = { split: 'right' }
    else
      atom.workspace.activateNextPane()

    methodNames = @getMethodNames(lines)
    promise = atom.workspace.open(openFilePath, openOptions)
    promise.then (editor) ->
      if editor.isEmpty()
        editor.insertText("Defined Methods\n")
        editor.insertText(methodNames.join("\n"))
