RailsOpenRspecView = require './rails-open-rspec-view'
{CompositeDisposable} = require 'atom'
{TextEditor} = require 'atom'

fs = require 'fs'
Path = require 'path'

RAILS_ROOT = atom.project.getPaths()[0]

String::camelize =->
  @replace /(^|\-|\_)(\w)/g, (a,b,c)->
    c.toUpperCase()


module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "rails-open-rspec:open-rspec-file", => @openSpec()

  openSpec: ->
    #camelize('aaaa_uuuu')
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
    basename = Path.basename(openFilePath)
    promise = atom.workspace.open(openFilePath, openOptions)

    # check file type
    dirName = Path.dirname(openFilePath)
    if /\/models\//.test(dirName)
      type = 'model'
    else if /\/controllers\//.test(dirName)
      type = 'controller'
    else if /\/services\//.test(dirName)
      type = 'service'
    else
      type = null

    # TODO refactoring
    promise.then (editor) ->
      if editor.isEmpty()
        className = basename.replace(/\_spec.rb$/, '').camelize()
        atom.notifications.addInfo("Generate new spec")
        editor.insertText("require 'rails_helper'\n")
        editor.insertNewline()
        editor.insertText("RSpec.describe #{className}")

        if type?
          editor.insertText(", :type => :#{type} do\n")
        else
          editor.insertText(" do\n")

        for methodName in methodNames
          editor.insertText("  describe '##{methodName}' do\n", autoIndent: false)
          editor.insertText("  end\n", autoIndent: false)
          editor.insertNewline()
        editor.insertText("end")
