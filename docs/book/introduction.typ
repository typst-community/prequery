#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "book.typ": book-page, import-spec

#show: book-page.with(title: [Introduction])

_Prequery_ is a Typst package and command line tool for getting external information into Typst documents.
It allows you to break Typst's sandbox in a controlled way, achieving things that in TeX would be done through "#link("https://tex.stackexchange.com/questions/88740/what-does-shell-escape-do")[shell escape]".

The #link("https://typst.app/universe/package/prequery")[Prequery package] allows you to prepare your documents so that they provide information to tools outside the sandbox.
See #cross-link("/quickstart/documents.typ")[Using Prequery in documents] on how to use it.

The #link("https://github.com/typst-community/prequery-preprocess")[`prequery` CLI tool] is one such tool that can process this information to prepare results for use inside your documents.
See #cross-link("/quickstart/installation.typ")[Installation] and #cross-link("/quickstart/preprocessor.typ")[Running the preprocessor] on how to use that.

Using external tools means that documents using _Prequery_ are no longer platform independent.
The `prequery` tool is available for Linux, Windows and Mac, but other tools may not be.
Projects in the web app are not supported, as you can't run external tools there.

= Early stage

_Prequery_ is still in early development; it works as an end-to-end solution to download files needed by your document from the web, and there is early support for running arbitrary shell commands.
If you need other features, feel free to open an issue on #link("https://github.com/typst-community/prequery/issues")[the package] or #link("https://github.com/typst-community/prequery-preprocess/issues")[the CLI tool].
You can also build your own features on top of what's already there and pull requests are welcome.

There are several other use cases that could be solved by a prequery-supported workflow:

- Pre-rendering diagrams using tools such as #link("https://plantuml.com/")[PlantUML], #link("https://mermaid.js.org/")[Mermaid.js], or #link("https://pintorajs.vercel.app/docs/intro/")[Pintora].
  (For the latter, there is also #link("https://typst.app/universe/package/pintorita")[Pintorita], which runs inside Typst.)

- Using Typst for literate programming/executable notebooks, like #link("https://typst.app/universe/package/jlyfish")[jlyfish] allows for Julia.

- ... anything else where excellent native tools are available but are not accessible from Typst directly.

(If you have another tool that someone finding Prequery may be interested in, let us know so that we can add a link here!)
