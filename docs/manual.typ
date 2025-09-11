#import "template.typ" as template: *
#import "/src/lib.typ" as prequery

#import "@preview/crudo:0.1.1"

#show: manual(
  package-meta: toml("/typst.toml").package,
  title: "Prequery",
  subtitle: "Extracting metadata for preprocessing from a typst document, for example image URLs for download from the web.",
  date: datetime(year: 2025, month: 9, day: 12),

  // logo: rect(width: 5cm, height: 5cm),
  abstract: [
    Typst compilations are sandboxed: it is not possible for Typst packages or documents to access the "outside world".
    This sandboxing has good reasons, but as a consequence certain tasks require more manual work than one may like.
    For example, if you want to embed an image from the internet in your document, you need to download the image using its URL, save the image in your Typst project, and then show that file using the `image()` function.
    Prequery offers a limited interface that makes it easier to automate tasks of this kind.
  ],

  scope: (prequery: prequery),
)

= Introduction

_Prequery_ is a Typst package and command line tool for getting external information into Typst documents.
It allows you to break Typst's sandbox in a controlled way, achieving things that in TeX would be done through "#link("https://tex.stackexchange.com/questions/88740/what-does-shell-escape-do")[shell escape]".

The #link("https://typst.app/universe/package/prequery")[Prequery package] allows you to prepare your documents so that they provide information to tools outside the sandbox.
The #link("https://github.com/typst-community/prequery-preprocess")[`prequery` CLI tool] is one such tool that can process this information to prepare results for use inside your documents.

This manual only contains generated API docs for the Typst package.
For other usage information, see the online book: https://typst-community.github.io/prequery/

= Module reference

#module(
  read("/src/lib.typ"),
  name: "prequery",
  label-prefix: none,
)
