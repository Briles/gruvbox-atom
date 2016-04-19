{SelectListView} = require 'atom-space-pen-views'

class GruvboxSelectListView extends SelectListView

  initialize: (@gruvbox) ->
    super
    @list.addClass 'mark-active'
    @setItems @getThemes()

  viewForItem: (theme) ->
    element = document.createElement 'li'
    if @gruvbox.isConfigTheme theme.brightness, theme.contrast
      element.classList.add 'active'
    element.textContent = theme.name
    element

  getFilterKey: ->
    'name'

  selectItemView: (view) ->
    super
    theme = @getSelectedItem()
    @gruvbox.isPreview = true
    @gruvbox.enableTheme theme.brightness, theme.contrast if @attached

  confirmed: (theme) ->
    @confirming = true
    @gruvbox.isPreview = false
    @gruvbox.isPreviewConfirmed = true
    @gruvbox.setThemeConfig theme.brightness, theme.contrast
    @cancel()
    @confirming = false

  cancel: ->
    super
    @gruvbox.enableConfigTheme() unless @confirming
    @gruvbox.isPreview = false
    @gruvbox.isPreviewConfirmed = false

  cancelled: ->
    @panel?.destroy()

  attach: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @selectItemView @list.find 'li:last'
    @selectItemView @list.find '.active'
    @focusFilterEditor()
    @attached = true

  getThemes: ->
    console.log('working');
    brightnesses = atom.config.getSchema("#{@gruvbox.packageName}.brightness").enum
    if atom.config.get "#{@gruvbox.packageName}.matchUserInterfaceTheme"
      contrasts = [atom.config.defaultSettings["#{@gruvbox.packageName}"].contrast]
    else
      contrasts = atom.config.getSchema("#{@gruvbox.packageName}.contrast").enum
    themes = []
    brightnesses.forEach (brightness) -> contrasts.forEach (contrast) ->
      themes.push brightness: brightness, contrast: contrast, name: "gruvbox (#{brightness}) (#{contrast})"
    themes

module.exports = GruvboxSelectListView
