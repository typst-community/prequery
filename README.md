# Prequery

This package helps extracting metadata for preprocessing from a typst document, for example image URLs for download from the web.
Typst compilations are sandboxed: it is not possible for Typst packages, or even just a Typst document itself, to access the "ouside world".
This sandboxing of Typst has good reasons.
Yet, it is often convenient to trade a bit of security for convenience by weakening it.
Prequery helps with that by providing some simple scaffolding for supporting preprocessing of documents.

The Prequery documentation is located at https://typst-community.github.io/prequery/; for now, the package API is still in the [PDF manual](docs/manual.pdf).

## Getting Started

Here's an example for referencing images from the internet:

```typ
#import "@preview/prequery:0.1.0"

// toggle this comment or pass `--input prequery-fallback=true` to enable fallback
// #prequery.fallback.update(true)

#prequery.image(
  "https://raw.githubusercontent.com/typst-community/prequery/refs/heads/main/test-assets/example-image.svg",
  "assets/example-image.svg")
```

Using `typst query`, the image URL(s) are extracted from the document:

```sh
typst query --input prequery-fallback=true --field value \
    main.typ '<web-resource>'
```

This will output the following piece of JSON:

```json
[{"url": "https://raw.githubusercontent.com/typst-community/prequery/refs/heads/main/test-assets/example-image.svg", "path": "assets/example-image.svg"}]
```

Which can then be used to download all images to the expected locations.
One option to do so is to use the `prequery` preprocessor; you can look at the [Quickstart section](https://typst-community.github.io/prequery/quickstart/installation.html) to learn how.
