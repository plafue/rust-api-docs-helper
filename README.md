# rust-api-docs-helper package

Opens the rust docs in an external browser when using the trigger hotkey on a ```use std::_``` import line. Displaying other standard crates is also supported but may not work properly at the moment.

It attempts to figure out which documentation is available for the import string (e.g. is it a struct, a function, a trait or a module?).

## Future plans
* ~~~Opening the docs for a module or crate.~~~
* Visual aid (e.g. on-hover "Docs available for this import" hint).
* Internal browser?
