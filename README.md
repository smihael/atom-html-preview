# Atom WebPPL Support

WebPPL & WebPPL-viz support with a live preview tool for Atom Editor. 

Install:
```bash
git clone https://github.com/smihael/atom-webppl-preview
cd atom-webppl-preview
apm link
```
Alternativelly (if you have atom shell extensions installed), you can just use `apm install https://github.com/smihael/atom-webppl-preview.git`.

To tggle Live Preview, you can either press `ctrl-alt-w` in the editor to open the preview pane or find it in the Plugins menu.

An example with dummy WebPPL code

![Live Preview](https://raw.githubusercontent.com/smihael/atom-webppl-preview/master/webppl-atom.gif)

For syntax highlighting I recommend installing `file-types` package and adding the following vode to `config.cson`:
```coffeescript
  "file-types":
    webppl: "source.js"
    wppl: "source.js"
```


## Ackwnowlegments
- https://github.com/harmsk/atom-html-preview
- https://github.com/atom/markdown-preview
