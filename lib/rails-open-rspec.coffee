RailsOpenRspecView = require './rails-open-rspec-view'
{CompositeDisposable} = require 'atom'

fs = require 'fs'
Path = require 'path'

RAILS_ROOT = atom.project.resolve('./')

module.exports =
  #railsOpenRspecView: null
  #modalPanel: null
  #subscriptions: null

  activate: (state) ->
    atom.commands.add 'atom-workspace', "rails-open-rspec:open-rspec-file", => @openSpec()

  ###
  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @railsOpenRspecView.destroy()

  serialize: ->
    railsOpenRspecViewState: @railsOpenRspecView.serialize()
  ###
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
