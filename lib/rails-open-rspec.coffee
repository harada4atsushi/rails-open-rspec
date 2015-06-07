RailsOpenRspecView = require './rails-open-rspec-view'
{CompositeDisposable} = require 'atom'

fs = require 'fs'
Path = require 'path'

RAILS_ROOT = atom.project.getPaths()[0]

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "rails-open-rspec:open-rspec-file", => @openSpec()

  openSpec: ->
    console.log "RAIL_ROOT => #{RAILS_ROOT}"

    editor = atom.workspace.getActiveTextEditor()
    currentFilepath = editor.getPath()
    console.log "currentFilepath => #{currentFilepath}"

    specFilepath = @findSpecFilepath(currentFilepath)
    console.log "specFilepath => #{specFilepath}"

    if fs.existsSync specFilepath
      console.log 'file exists!'
      atom.workspace.open(specFilepath, split: 'right')

  findSpecFilepath: (currentFilepath) ->
    relativePath = currentFilepath.substring(RAILS_ROOT.length)
    specFilepath = relativePath.replace /\.rb$/, '_spec.rb'
    specFilepath = specFilepath.replace /^\/app\//, "/spec/"
    Path.join RAILS_ROOT, specFilepath
