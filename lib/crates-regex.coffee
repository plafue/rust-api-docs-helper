# This regex cuts until the first comma or a semicollon (e.g. "std::sync::{Arc," or "std::sync::Arc;")
# This list of crages is based on the current list @ http://doc.rust-lang.org/ at the time of this commit

module.exports = CratesRegex = /// (
    (alloc
    |arena
    |collections
    |core
    |flate
    |fmt_macros
    |getopts
    |graphviz
    |libc
    |log
    |rand
    |rbml
    |rustc
    |rustc_back
    |rustc_bitflags
    |rustc_borrowck
    |rustc_data_structures
    |rustc_driver
    |rustc_lint
    |rustc_llvm
    |rustc_privacy
    |rustc_resolve
    |rustc_serialize
    |rustc_trans
    |rustc_typeck
    |rustc_unicode
    |rustdoc
    |std
    |syntax
    |term
    |test)
    ::\S*)
    [,;]
  ///
