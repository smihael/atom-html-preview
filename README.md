# Atom WebPPL Support

WebPPL support with a live preview tool for Atom Editor.

Install:
```bash
git clone https://github.com/smihael/atom-webppl-preview
cd atom-webppl-preview
apm link
```

Toggle Live Preview:

Press `ctrl-shift-w` in the editor to open the preview pane.

<!--
![Atom HTML Preview](https://dl.dropboxusercontent.com/u/20947008/webbox/atom/atom-html-preview.png)

An example with [Twitter Bootstrap 3 Package][1]

![Atom HTML Preview with Bootstrap](https://dl.dropboxusercontent.com/u/20947008/webbox/atom/atom-bootstrap-3.gif)

[1]: http://atom.io/packages/atom-bootstrap3
-->

For syntax highlighting I recommend installing `file-types` package and adding the following vode to `config.cson`:
```coffeescript
  "file-types":
    webppl: "source.js"
    wppl: "source.js"
```


## Ackwnowlegments
- https://github.com/harmsk/atom-html-preview
- https://github.com/atom/markdown-preview
