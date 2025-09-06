#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ": book-page

#show: book-page.with(title: [Web resources])

Downloads files from the web.
If a file required by the document exists already, it is not re-downloaded by default.
This preprocessor can be used in combination with the #link("https://typst.app/universe/package/prequery")[Prequery package's] `image()` function.

= Configuration & defaults

```toml
[[tool.prequery.jobs]]
name = "..."  # required
kind = "web-resource"

# the query getting metadata from the document
# see https://typst.app/docs/reference/introspection/query/#command-line-queries
query.selector = "<web-resource>"
query.field = "value"
# query.one = false  # this can not be changed for web-resource jobs

# force re-downloading existing files
overwrite = false
# can be set to `true` or a file name to keep a file with all known resources
index = false
```
// # if `true` and there is an index file, delete files no longer in the document
// evict = false

= Index

The `web-resource` preprocessor can optionally keep an index file.
This means it will know what local files come from resources and can do a better job keeping local files and resources specified in the document in sync.
If `index = true` is configured, the default index file name `web-resource-index.toml` is used.

When using an index, `web-resource` keeps track of all file names and and URLs in the document.
If a file is present, but the associated URL changes, the resource will be re-downloaded;
this is different from the default behavior, where an existing file would never be re-downloaded (since the preprocessor also doesn't know what URL the file previously came from).

// If an index is used, `web-resource` knows what existing files were downloaded by it.
// By additionally specifying `evict = true`, the preprocessor will delete files in the index that don't appear in the document any more.
