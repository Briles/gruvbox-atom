## Adapted from https://github.com/Alchiadus/base16-syntax

fs = require 'fs'
path = require 'path'
{CompositeDisposable} = require 'atom'

class Gruvbox

  config: require('./gruvbox-settings').config

  activate: ->

    @disposables = new CompositeDisposable
    @packageName = require('../package.json').name
    @disposables.add atom.config.observe "#{@packageName}.brightness", => @enableConfigTheme()
    @disposables.add atom.config.observe "#{@packageName}.contrast", => @enableConfigTheme()
    @disposables.add atom.commands.add 'atom-workspace', "#{@packageName}:select-theme", @createSelectListView

  deactivate: ->
    @disposables.dispose()

  enableConfigTheme: ->
    brightness = atom.config.get "#{@packageName}.brightness"
    contrast = atom.config.get "#{@packageName}.contrast"
    @enableTheme brightness, contrast

  enableTheme: (brightness, contrast) ->
    # No need to enable the theme if it is already active.
    return if @isActiveTheme brightness, contrast unless @isPreviewConfirmed
    try
      # Write the requested theme to the `syntax-variables` file.
      fs.writeFileSync @getSyntaxVariablesPath(), @getSyntaxVariablesContent(brightness, contrast)
      activePackages = atom.packages.getActivePackages()
      if activePackages.length is 0 or @isPreview
        # Reload own stylesheets to apply the requested theme.
        atom.packages.getLoadedPackage("#{@packageName}").reloadStylesheets()
      else
        # Reload the stylesheets of all packages to apply the requested theme.
        activePackage.reloadStylesheets() for activePackage in activePackages
      @activeScheme = brightness
      @activeStyle = contrast
    catch
      # If unsuccessfull enable the default theme.
      @enableDefaultTheme()

  isActiveTheme: (brightness, contrast) ->
    brightness is @activeBrightness and contrast is @activeContrast

  getSyntaxVariablesPath: ->
    path.join __dirname, "..", "styles", "syntax-variables.less"

  getSyntaxVariablesContent: (brightness, contrast) ->
    """
    @import 'schemes/#{brightness.toLowerCase()}-#{contrast.toLowerCase()}';
    @import 'schemes/#{brightness.toLowerCase()}';
    @import 'colors';
    """

  enableDefaultTheme: ->
    brightness = atom.config.getDefault "#{@packageName}.brightness"
    contrast = atom.config.getDefault "#{@packageName}.contrast"
    @setThemeConfig brightness, contrast

  setThemeConfig: (brightness, contrast) ->
    atom.config.set "#{@packageName}.brightness", brightness
    atom.config.set "#{@packageName}.contrast", contrast

  createSelectListView: =>
    GruvboxSelectListView = require './gruvbox-select-list-view'
    gruvboxSelectListView = new GruvboxSelectListView @
    gruvboxSelectListView.attach()

  isConfigTheme: (brightness, contrast) ->
    configBrightness = atom.config.get "#{@packageName}.brightness"
    configContrast = atom.config.get "#{@packageName}.contrast"
    brightness is configBrightness and contrast is configContrast

module.exports = new Gruvbox
