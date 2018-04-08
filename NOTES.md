# Technical specification
* The preview pane is inherited from https://github.com/electron/electron/blob/master/docs/api/browser-window.md, thus we can only load URLs, i.e. local files (via the `files://` protocol), remote locations or HTML code using the `data://` protocol (check performance issues)
* WebPPL-viz assumes some objects, that are initialized by WebPPL-editor. Workaround is provided in the `overrides.js` file

# Known problems
* `Uncaught TypeError: k is not a function` with execution using `webppl.run()`
* `print()` doesn't work as expected (opens print dialog instead of showing the values); you can use `display()` instead
* Infer statements don't show anything (they should be wrapped either with `viz()` or `display()`)
