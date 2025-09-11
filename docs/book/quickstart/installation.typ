#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ": book-page

#show: book-page.with(title: [Installation])

If you plan to use the #link("https://github.com/typst-community/prequery-preprocess")[`prequery` CLI tool], you will need to install it on your system.
This is not necessary to run other external tools in combination with the #link("https://typst.app/universe/package/prequery")[Prequery package].

= Download from GitHub

You can download pre-built binaries of all stable versions from the #link("https://github.com/typst-community/prequery-preprocess/releases")[release page] of the CLI tool's GitHub repository, these are automatically built for Linux, Windows, and Mac. Nightly versions are not pre-built.

After you downloaded the correct archive for your operating system and architecture you have to extract them and place the `prequery` binary somewhere in your `$PATH`.

= Using cargo-binstall

The most straight forward way to install Prequery is to use #link("https://crates.io/crates/cargo-binstall")[`cargo-binstall`], this saves you the hassle of compiling from source.

`prequery` is so far not published on #link("https://crates.io/")[crates.io], so you need to install by refrencing the git repository:

```bash
cargo binstall --git https://github.com/typst-community/prequery-preprocess prequery-preprocess
```

= Installation From Source

To install Prequery from source, you must have a Rust toolchain (Rust v1.85.0+) and `cargo` installed, you can get these using #link("https://www.rust-lang.org/tools/install")[`rustup`].

== Stable

```bash
cargo install --locked --git https://github.com/typst-community/prequery-preprocess --tag v0.2.0
```

== Nightly

```bash
cargo install --locked --git https://github.com/typst-community/prequery-preprocess
```

This method usually doesn't require manually placing the Prequery binary in your `$PATH` because the cargo binary directory should already be in there.

== Dependencies

When building from source, you can optionally use the `native-tls-vendored` feature to vendor OpenSSL on Linux.
See the #link("https://docs.rs/native-tls/latest/native_tls/#cargo-features")[`native_tls` crate's `vendored` feature] for details.