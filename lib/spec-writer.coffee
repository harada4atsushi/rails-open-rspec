Path = require 'path'
Fs = require 'fs'

module.exports =
class SpecWriter
  constructor: (@editor, @sourceEditor) ->
    @specType = @judgeSpecType()
    @helperName = @helperNameBeRequire()
    @methodNames = @detectMethodNames()
    @className = @detectClassName()

  write: ->
    @editor.insertText("require '#{@helperName}'\n")
    @editor.insertNewline()
    @editor.insertText("RSpec.describe #{@className}")

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

  detectMethodNames: ->
    lines = @sourceEditor.getBuffer().getLines()
    defLines = lines.map (line) ->
      arr = line.match(/^\s*def ([^\(]*)/)
      arr[1] if arr

    defLines.filter (line) -> line?

  detectClassName: ->
    #basename = Path.basename(@editor.getPath())
    #className = basename.replace(/\_spec.rb$/, '').camelize()
    lines = @sourceEditor.getBuffer().getLines()
    arr = lines.filter (line) ->
      /^\s*class\s.*/.test(line)

    return null if arr.count == 0

    classNameLine = arr[0]
    expResult = classNameLine.match(/^\s*class\s(\S*)/)
    expResult[1]

  helperNameBeRequire: ->
    rootPath = atom.project.getPaths()[0]
    if Fs.existsSync("#{rootPath}/spec/rails_helper.rb")
      'rails_helper'
    else
      'spec_helper'
