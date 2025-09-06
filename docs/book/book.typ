#import "@preview/crudo:0.1.1"
#import "@preview/shiroa:0.2.3": *

#show: book

// re-export page template
#import "contrib/typst/gh-pages.typ": project as book-page, heading-reference

#let meta = toml("/typst.toml").package

#show: summary => book-meta(
  title: "Prequery Preprocessor",
  description: meta.description,
  repository: meta.repository,
  authors: meta.authors,
  language: "en",
  summary: summary,
)

#prefix-chapter("introduction.typ")[Introduction]
