# Atom WebPPL Support

[WebPPL](http://webppl.org/) & [WebPPL-viz](http://probmods.github.io/webppl-viz/) support with a live preview tool for Atom Editor.

## Installation
```bash
apm install atom-webppl-preview
```

Alternativelly (if you want to fetch the newest version), you can just use `apm install https://github.com/smihael/atom-webppl-preview.git`.

To toggle Live Preview, you can either press `ctrl-alt-h` in the editor to open the preview pane or find it in the Plugins menu.

## Example
An example with dummy WebPPL code

![Live Preview](https://raw.githubusercontent.com/smihael/atom-webppl-preview/master/webppl-atom.gif)

## Syntax highlighting
For syntax highlighting, the instalation of `file-types` package is recomended. By adding the following code to `config.cson`:
```coffeescript
  "file-types":
    webppl: "source.js"
    wppl: "source.js"
```
files with `.webppl` or `.wppl` ending will be highlighted according to JavaScript grammar.

## Other IDEs
Users of other IDEs can use `html/index.html` file from this project in conjunction with your favourite browser. Use the integrated "Open in Browser" option from the context menu in Sublime (make sure you enable `--allow-file-access-from-files` flag in Chrome), [LiveReload](https://packagecontrol.io/packages/LiveReload) package for Sublime (if you want to get the rerender as you save behaviour) or [Live Server](https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer) extension for Visual Studio Code.

This approach exploits [location hash](https://www.w3schools.com/jsref/prop_loc_hash.asp) property to read content of your webppl script into the web compiler.  You can either set it manually (like `http://localhost:5500/atom-webppl-preview/html/index.html#file=../../test.webppl`) or enter it into prompt.

## Acknowledgments
This package is based on:
- https://github.com/harmsk/atom-html-preview
