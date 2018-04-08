# Technical specification
* The preview pane is inherited from https://github.com/electron/electron/blob/master/docs/api/browser-window.md, thus we can only load URLs, i.e. local files (via the `files://` protocol) or remote locations; rendering HTML code using the `data://` protocol runs into problems (apparently remote stylesheets can't be resolved then)
* WebPPL-viz assumes some objects, that are initialized by WebPPL-editor. Workaround is provided in the `overrides.js` file

* When "Toogle Preview on Save" is checked, we read directly from file (https://stackoverflow.com/questions/16387192/read-file-to-string-with-coffeescript-and-node-js) and only render WebPPL preview when save event is detected, otherwise we copy webppl script directly from the editor


# Known problems
* `Uncaught TypeError: k is not a function` with execution using `webppl.run()`: FIXED
* `print()` doesn't work as expected (opens print dialog instead of showing the values); you can use `display()` instead
* Infer statements don't show anything (they should be wrapped either with `viz()` or `display()`)

#TODOs:
* Activate plugin only when WebPPL file is opened (to be able to do so, WebPPL specific language grammar should be provided first)
* Add npm dependencies to WebPPL to support completely offline workflow
* Investigate on how to make most of the HTML static (look at the showError implementation for this) and only reload portion with the script and not the entire page
** or maybe use string replacement on index.html template
* Only rerender html preview when the actual script is changed (currently this is bound to the editor generally, so no mather which file you change, the preview gets updated)
** Alternatively: close the preview when leaving the script (might be unuseful when we import scripts in the main script)
