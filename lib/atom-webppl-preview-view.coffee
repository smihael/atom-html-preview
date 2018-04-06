fs                    = require 'fs'
{CompositeDisposable, Disposable} = require 'atom'
{$, $$$, ScrollView}  = require 'atom-space-pen-views'
path                  = require 'path'
os                    = require 'os'

runWpScript = """
<script>

</script>
"""

pluginDir = __dirname


module.exports =
class AtomHtmlPreviewView extends ScrollView
  atom.deserializers.add(this)

  editorSub           : null
  onDidChangeTitle    : -> new Disposable()
  onDidChangeModified : -> new Disposable()

  webviewElementLoaded : false
  renderLater : true

  @deserialize: (state) ->
    new AtomHtmlPreviewView(state)


  @content: ->
    @div class: 'atom-webppl-preview native-key-bindings', tabindex: -1, =>
      style = 'z-index: 2; padding: 2em;'
      @div class: 'show-error', style: style
      @tag 'webview', src: path.resolve(__dirname, '../html/loading.html'), outlet: 'htmlview', disablewebsecurity:'on', allowfileaccessfromfiles:'on', allowPointerLock:'on' # preload:loadURL('data:text/javascript,var fileUrl="'+@getPath+'"')

  constructor: ({@editorId, filePath}) ->
    super

    if @editorId?
      @resolveEditor(@editorId)
      @tmpPath = @getPath() # after resolveEditor
    else
      if atom.workspace?
        @subscribeToFilePath(filePath)
      else
        # @subscribe atom.packages.once 'activated', =>
        atom.packages.onDidActivatePackage =>
          @subscribeToFilePath(filePath)

    # Disable pointer-events while resizing
    handles = $("atom-pane-resize-handle")
    handles.on 'mousedown', => @onStartedResize()

    #@find('.show-error').hide()
    @webview = @htmlview[0]

    @webview.addEventListener 'dom-ready', =>
      @webviewElementLoaded = true
      if @renderLater
        @renderLater = false
        @renderHTMLCode()


  onStartedResize: ->
    @css 'pointer-events': 'none'
    document.addEventListener 'mouseup', @onStoppedResizing.bind this

  onStoppedResizing: ->
    @css 'pointer-events': 'all'
    document.removeEventListener 'mouseup', @onStoppedResizing

  serialize: ->
    deserializer : 'AtomHtmlPreviewView'
    filePath     : @getPath()
    editorId     : @editorId

  destroy: ->
    if @editorSub?
      @editorSub.dispose()

  subscribeToFilePath: (filePath) ->
    @trigger 'title-changed'
    @handleEvents()
    @renderHTML()

  resolveEditor: (editorId) ->
    resolve = =>
      @editor = @editorForId(editorId)

      if @editor?
        @trigger 'title-changed' if @editor?
        @handleEvents()
      else
        # The editor this preview was created for has been closed so close
        # this preview since a preview cannot be rendered without an editor
        atom.workspace?.paneForItem(this)?.destroyItem(this)

    if atom.workspace?
      resolve()
    else
      # @subscribe atom.packages.once 'activated', =>
      atom.packages.onDidActivatePackage =>
        resolve()
        @renderHTML()

  editorForId: (editorId) ->
    for editor in atom.workspace.getTextEditors()
      return editor if editor.id?.toString() is editorId.toString()
    null

  handleEvents: =>
    contextMenuClientX = 0
    contextMenuClientY = 0

    @on 'contextmenu', (event) ->
      contextMenuClientY = event.clientY
      contextMenuClientX = event.clientX

    atom.commands.add @element,
      'atom-webppl-preview:open-devtools': =>
        @webview.openDevTools()
      'atom-webppl-preview:inspect': =>
        @webview.inspectElement(contextMenuClientX, contextMenuClientY)
      'atom-webppl-preview:print': =>
        @webview.print()
      'atom-webppl-preview:refresh': =>
        @webview.reload()


    changeHandler = =>
      @renderHTML()
      pane = atom.workspace.paneForURI(@getURI())
      if pane? and pane isnt atom.workspace.getActivePane()
        pane.activateItem(this)

    @editorSub = new CompositeDisposable

    if @editor?
      if atom.config.get("atom-webppl-preview.triggerOnSave")
        @editorSub.add @editor.onDidSave changeHandler
      else
        @editorSub.add @editor.onDidStopChanging changeHandler
      @editorSub.add @editor.onDidChangePath => @trigger 'title-changed'

  renderHTML: ->
    # if @editor?
    #   if not atom.config.get("atom-webppl-preview.triggerOnSave") && @editor.getPath()?
    #     @save(@renderHTMLCode)
    #   else
    #     @renderHTMLCode()
    @renderHTMLCode()

  save: (callback) ->

    #todo: https://stackoverflow.com/questions/16387192/read-file-to-string-with-coffeescript-and-node-js

    # Temp file path
    outPath = path.resolve path.join(os.tmpdir(), @editor.getTitle() + ".html")
    out = ""
    fileEnding = @editor.getTitle().split(".").pop()

    if atom.config.get("atom-webppl-preview.enableWpViz")
      out += """
        <script src="http://cdn.webppl.org/webppl-viz-0.7.11.js"></script>
        <script crossorigin src="https://unpkg.com/react@16/umd/react.production.min.js"></script>
        <script crossorigin src="https://unpkg.com/react-dom@16/umd/react-dom.production.min.js"></script>
      """

    out += "<base href=\"" + @getPath() + "\">"

    # Scroll into view
    editorText = @editor.getText()
    #{runWpScript}

    out += editorText

    @outExport = out

    @tmpPath = outPath
    fs.writeFile outPath, out, =>
      try
        @renderHTMLCode()
      catch error
        @showError error

  renderHTMLCodeDbg: () ->
    @htmlview.show()
    @webview.openDevTools()
    #@webview.webContents.onLoad()

  renderHTMLCode: () ->
    #@find('.show-error').hide()
    @htmlview.show()

    if @webviewElementLoaded
      #we deal with https://github.com/electron/electron/blob/master/docs/api/browser-window.md
      #@webview.loadURL("file://" + @tmpPath)
      #@webview.loadURL("file://" + path.resolve(__dirname, '../html/index.html'))
      @webview.loadURL("file://" + path.resolve(__dirname, '../html/index.html')+"#file="+@tmpPath)
      #@webview.loadURL('data:text/html,<textarea>'+@tmpPath+'</textarea>')
      #@webview.loadURL("data:text/html,"+@outExport)

      atom.commands.dispatch 'atom-webppl-preview', 'html-changed'
    else
      @renderLater = true


  getTitle: ->
    if @editor?
      "Preview #{@editor.getTitle()}"
    else
      "WebPPL Preview"

  getURI: ->
    "wppl-preview://editor/#{@editorId}"

  getPath: ->
    if @editor?
      @editor.getPath()

  showError: (result) ->
    failureMessage = result?.message

    @htmlview.hide()
    @find('.show-error')
    .html $$$ ->
      @h2 'Previewing HTML Failed'
      @h3 failureMessage if failureMessage?
    .show()
