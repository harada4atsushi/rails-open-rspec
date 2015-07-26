Path = require 'path'
Fs = require 'fs'

# HACK DRY
RAILS_ROOT = atom.project.getPaths()[0]

module.exports =
class SpecWriter
  constructor: (@editor, @methodNames) ->
    @specType = @judgeSpecType()
    @helperName = @helperNameBeRequire()

  write: ->
    basename = Path.basename(@editor.getPath())
    className = basename.replace(/\_spec.rb$/, '').camelize()

    @editor.insertText("require '#{@helperName}'\n")
    @editor.insertNewline()
    @editor.insertText("RSpec.describe #{className}")

    if @specType?
      @editor.insertText(", :type => :#{@specType} do\n")
    else
      @editor.insertText(" do\n")

    for methodName in @methodNames
      @editor.insertText("  describe '##{methodName}' do\n", autoIndent: false)
      @editor.insertText("  end\n", autoIndent: false)
      @editor.insertNewline()
    @editor.insertText("end")

  judgeSpecType: ->
    dirName = Path.dirname(@editor.getPath())
    if /\/models$/.test(dirName)
      type = 'model'
    else if /\/controllers$/.test(dirName)
      type = 'controller'
    else if /\/services$/.test(dirName)
      type = 'service'
    else
      type = null
    type

  helperNameBeRequire: ->
    if Fs.existsSync("#{RAILS_ROOT}/spec/rails_helper.rb")
      'rails_helper'
    else
      'spec_helper'
