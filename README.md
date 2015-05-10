# rust-api-docs-helper package

Check out the [demo](https://github.com/plafue/rust-api-docs-helper/blob/master/demo/demo.mp4?raw=true).

## What this package can do
* Opening (via key binding) the docs for a module, crate, trait, function or struct from the official crates listed under [The Rust Standard Library](http://doc.rust-lang.org/std/) (the cursor must be positioned in the corresponding ``use xxx::xxx`` line).
* Can display the docs within atom if an internal browser (e.g. [mark-hahn/web-browser](https://atom.io/packages/web-browser)) is installed.

## Future plans
* Visual aid (e.g. on-hover "Docs available for this import" hint, icon in gutter, or similar).
* Make cache persistent between sessions (won't work until atom/atom#3695 is fixed).
