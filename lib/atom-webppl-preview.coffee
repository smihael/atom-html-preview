url                   = require 'url'
{CompositeDisposable} = require 'atom'

HtmlPreviewView       = require './atom-webppl-preview-view'

module.exports =
  config:
    triggerOnSave:
      type: 'boolean'
      description: 'Watch will trigger on save.'
      default: true
    runWp:
      type: 'boolean'
      description: 'Inject WebPPL run call'
      default: true
    enableWpViz:
      type: 'boolean'
      description: 'Enable WebPPL viz rendering'
      default: true

  htmlPreviewView: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      @subscriptions.add editor.onDidSave =>
        if htmlPreviewView? and htmlPreviewView instanceof HtmlPreviewView
          htmlPreviewView.renderHTML()

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-webppl-preview:toggle': => @toggle()

    atom.workspace.addOpener (uriToOpen) ->
      try
        {protocol, host, pathname} = url.parse(uriToOpen)
      catch error
        return

      return unless protocol is 'html-preview:'

      try
        pathname = decodeURI(pathname) if pathname
      catch error
        return

      if host is 'editor'
        @htmlPreviewView = new HtmlPreviewView(editorId: pathname.substring(1))
      else
        @htmlPreviewView = new HtmlPreviewView(filePath: pathname)

      return htmlPreviewView

  toggle: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    uri = "html-preview://editor/#{editor.id}"

    previewPane = atom.workspace.paneForURI(uri)
    if previewPane
      previewPane.destroyItem(previewPane.itemForURI(uri))
      return

    previousActivePane = atom.workspace.getActivePane()
    atom.workspace.open(uri, split: 'right', searchAllPanes: true).then (htmlPreviewView) ->
      if htmlPreviewView instanceof HtmlPreviewView
        htmlPreviewView.renderHTML()
        previousActivePane.activate()

  deactivate: ->
    @subscriptions.dispose()
