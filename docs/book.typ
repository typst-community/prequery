#import "@preview/haita:0.4.0" as haita: *

#import "/src/lib.typ" as prequery
#import "template.typ": set-info, _haita_path_str

#set-info(
  package-meta: toml("/typst.toml").package,
  scope: (prequery: prequery),
)

#let chapter(path, filename: auto, content: auto, ..args) = haita.chapter(
  path,
  content: {
    _haita_path_str.update(path)
    if content != auto {
      content
    } else {
      let filename = if filename != auto { filename } else { path }
      include "book/" + filename + ".typ"
    }
  },
  ..args,
)

#let (name, homepage) = toml("/typst.toml").package

#book(
  title: name,
  base-url: homepage,

  // This sets your html renderer. You can customize the HTML renderer
  // using `html-renderer.with(...)`, or write your own!
  html-renderer: new-hamber.html-renderer.with(
    sidebar-image: {
      show: html.h1.with(class: "p-4 text-xl font-bold italic")
      link("/" + name)[#name]
    },
    pagefind-enabled: true,
    footer-content: [
      Powered by #link("https://github.com/wensimehrp/haita")[Haita].
    ],
  ),
  // Your document's contents
  tree: (
    chapter("index", filename: "introduction"),
    chapter("limitations"),

    [= Quickstart],
    chapter("quickstart/installation"),
    chapter("quickstart/documents"),
    chapter("quickstart/preprocessor"),

    [= Typst Package],
    chapter("package/prequeries"),
    chapter("package/api"),

    [= Preprocessor kinds],
    chapter("preprocessors/web-resource"),
    chapter("preprocessors/shell"),
  ),
)

