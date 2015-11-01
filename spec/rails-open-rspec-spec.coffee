Path = require 'path'
{Workspace} = require 'atom'
RailsOpenRspec = require '../lib/rails-open-rspec'

describe "RailsOpenRspec", ->
  [workspaceElement, activationPromise] = []
  specFileOpened = null

  currentPath = ->
    atom.workspace.getActiveTextEditor().getPath()

  openRspecFile = (filePath) ->
    promise = atom.workspace.open(filePath)
    promise.then (editor) ->
      atom.commands.dispatch atom.views.getView(editor), 'rails-open-rspec:open-rspec-file'
      specFileOpened = true

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('rails-open-rspec')

  describe "when the rails-open-rspec:open-rspec-file event is triggered", ->
    it "open spec file", ->
      openRspecFile('app/models/hoge.rb')

      waitsFor ->
        specFileOpened

      runs ->
        # wait for open rspec file
        setTimeout ->
          console.log("")
        , 1000
        expect(currentPath()).toBe Path.join(__dirname, 'fixtures/spec/models/hoge_spec.rb')
