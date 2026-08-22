#import "@preview/haita:0.3.0": *

#import "/src/lib.typ" as prequery
#import "tidy.typ": set-info

#set-info(
  package-meta: toml("/typst.toml").package,
  scope: (prequery: prequery),
)

#book(
  title: "Prequery",
  canonical-url: "https://typst-community.github.io",
  root: "prequery",

  // This sets your html renderer. You can customize the HTML renderer
  // using `html-renderer.with(...)`, or write your own!
  html-renderer: new-hamber.html-renderer.with(
    sidebar-image: {
      show: html.h1.with(class: "p-4 text-xl font-bold italic")
      link("/prequery")[Prequery]
    },
    pagefind-enabled: true,
    footer-content: [
      Powered by #link("https://github.com/wensimehrp/haita")[Haita].
    ],
  ),
  // Your document's contents
  tree: (
    chapter("index", content: include "introduction.typ"),
    chapter("limitations", content: include "limitations.typ"),

    [= Quickstart],
    chapter("quickstart/installation", content: include "quickstart/installation.typ"),
    chapter("quickstart/documents", content: include "quickstart/documents.typ"),
    chapter("quickstart/preprocessor", content: include "quickstart/preprocessor.typ"),

    [= Typst Package],
    chapter("package/prequeries", content: include "package/prequeries.typ"),
    chapter("package/api", content: include "package/api.typ"),

    [= Preprocessor kinds],
    chapter("preprocessors/web-resource", content: include "preprocessors/web-resource.typ"),
    chapter("preprocessors/shell", content: include "preprocessors/shell.typ"),
  ),
)

