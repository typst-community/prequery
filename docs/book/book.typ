#import "@preview/crudo:0.1.1"
#import "@preview/shiroa:0.2.3": *

#show: book

// re-export page template
#import "contrib/typst/gh-pages.typ": project as book-page, heading-reference

#let meta = toml("/typst.toml").package
#let import-spec(namespace: "preview") = "@" + namespace + "/" + meta.name + ":" + meta.version

#show: summary => book-meta(
  title: "Prequery Preprocessor",
  description: meta.description,
  repository: meta.repository,
  authors: meta.authors,
  language: "en",
  summary: summary,
)

#prefix-chapter("introduction.typ")[Introduction]

= Quickstart
- #chapter("quickstart/installation.typ")[Installation]
- #chapter("quickstart/documents.typ")[Using Prequery in documents]
- #chapter("quickstart/preprocessor.typ")[Running the preprocessor]

= Typst Package
- #chapter("package/api.typ")[Prequery API]

= Preprocessor kinds
- #chapter("preprocessors/web-resource.typ")[Web resources]
