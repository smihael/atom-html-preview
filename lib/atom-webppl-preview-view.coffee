fs                    = require 'fs'
{CompositeDisposable, Disposable} = require 'atom'
{$, $$$, ScrollView}  = require 'atom-space-pen-views'
path                  = require 'path'
os                    = require 'os'

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
      @tag 'webview', src: path.resolve(__dirname, '../html/loading.html'), outlet: 'htmlview', disablewebsecurity:'on', allowfileaccessfromfiles:'on', allowPointerLock:'on'

  constructor: ({@editorId, filePath}) ->
    super

    if @editorId?
      @resolveEditor(@editorId)
      @webpplScriptPath = @getPath() # after resolveEditor

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

    @find('.show-error').hide()
    @webview = @htmlview[0]

    @webview.addEventListener 'dom-ready', =>
      @webviewElementLoaded = true
      if @renderLater
        @renderLater = false
        #@renderHTMLCode()
        @renderHTML()


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
    @tempSave(@renderHTMLCode)
    #@webview.openDevTools()

  webpplPreview: ->

    # get parameters
    webpplLibraryPath = atom.config.get("atom-webppl-preview.webpplLibraryLocation")
    webpplScriptText = @getWebpplScriptText().toString().replace /\n|\r/g, " \\n " #check OS compatibility

    # basically the same as index.html
    html = """
    <html lang="en">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>WebPPL live previewer</title>

      <!-- jQuery -->
      <script src="#{pluginDir}/../node_modules/jquery/dist/jquery.min.js"></script>

      <!-- WebPPL -->
      <script crossorigin src="#{webpplLibraryPath}"></script>
    """

    if atom.config.get("atom-webppl-preview.enableWebpplViz")
      html += """
      <!-- WebPPL viz and its dependencies -->
      <link rel="stylesheet" href="http://cdn.webppl.org/webppl-viz-0.7.6.css" />
      <script crossorigin src="http://cdn.webppl.org/webppl-viz-0.7.11.js"></script>
      <script crossorigin src="https://unpkg.com/react@16/umd/react.production.min.js"></script>
      <script crossorigin src="https://unpkg.com/react-dom@16/umd/react-dom.production.min.js"></script>
      """
    html += """
      <!-- Core functions -- >
      <base href="#{pluginDir}/../html/index.html" /> -->
      <link rel="stylesheet" href="#{pluginDir}/../html/style.css" />
      <script src="#{pluginDir}/../html/overrides.js"></script>
    </head>
    <body>
      <h1>
        <i><span class="logo-main">Web</span><span class="logo-bold">PPL</span> live preview</i>
      </h1>

      <div id="results">
        <!-- Result blocks will be injected here -->
      </div>

      <!-- Inject WebPPL code and run it -->
      <script>
        var text = '#{webpplScriptText}';
        webppl.run(text, function(s,x) {result = x});
      </script>

    </body>
    </html>
    """
    @htmlExport = html

  getWebpplScriptText: ->
    if @editor?
       if not atom.config.get("atom-webppl-preview.triggerPreviewOnSave") && @editor.getPath()?
         # get text from editor
         @editor.getText()
       else
         # get text from file
         fs.readFileSync @webpplScriptPath, 'utf-8'
   #TODO: output file location

  tempSave: (callback) ->
    # Temp file path
    @tmpPath = path.resolve path.join(os.tmpdir(), (@editor.getTitle().replace ".", "_")+"_preview.html")
    @showDbg "Rendering from "+@tmpPath

    html = @webpplPreview()

    fs.writeFile @tmpPath, html, =>
      try
        @renderHTMLCode()
      catch error
        @showError error


  renderHTMLCode: () ->
    @find('.show-error').hide()
    @htmlview.show()

    if @webviewElementLoaded
      @webview.loadURL("file://" + @tmpPath)

      # Legacy mode:
      #@webview.loadURL("file://" + path.resolve(__dirname, '../html/index.html')+"#file="+@webpplScriptPath)

      # Experimental:
      #htmlExport=@webpplPreview()
      #@webview.loadURL("data:text/html,#{htmlExport}")

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

  showDbg: (message) ->
    @find('.show-error')
    .html $$$ ->
      @h2 'Debug info:'
      @p message if message?
    .show()

  showError: (result) ->
    failureMessage = result?.message

    @htmlview.hide()
    @find('.show-error')
    .html $$$ ->
      @h2 'Previewing HTML Failed'
      @h3 failureMessage if failureMessage?
    .show()
