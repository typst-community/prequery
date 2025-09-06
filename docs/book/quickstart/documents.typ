#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ": book-page, import-spec

#show: book-page.with(title: [Using Prequery in documents])

Let's say you have a document with many images in them, and these images are available on the web.
Instead of manually downloading these images, you'd like to load these images from their respective URLs, something like this:

```typ
#figure(
  image("https://example.com/example.png"),
  caption: [An image],
)
```

Of course, this doesn't work; Typst doesn't allow you to access the internet.
You get an error like "file not found (searched at .../https:/example.com/example.png)."

While writing your document, the #link("https://typst.app/universe/package/prequery")[Prequery package] helps you embed the necessary metadata (here, image URLs) into your document:

#crudo.map(
  ```typ
  #import "PACKAGE_IMPORT": image

  // toggle this comment or pass `--input prequery-fallback=true` to enable fallback
  // #prequery.fallback.update(true)

  #figure(
    image("https://example.com/example.png", "example.png"),
    caption: [An image],
  )
  ```,
  l => l.replace("PACKAGE_IMPORT", import-spec()),
)

Here, `image()` is not Typst's built-in function, but Prequery's
(you can still use the original by writing `std.image()`, or not import the function directly and instead write `prequery.image()`).
This function takes a URL first and a filename second, so that an outside tool can know what to download and where to.

= Previewing without local images

Before the image was downloaded, your document won't compile.
If you still want to preview your document without the image, the code snippet above indicates what you can do:
activate the "fallback" option in code, or pass it on the command line:

```bash
typst compile --input prequery-fallback=true main.typ
```

(assuming your document is in a file `main.typ`)

= Next steps

At this point, you don't have your image inside your document yet -- for that, you'll need to #cross-link("/quickstart/preprocessor.typ")[run the `prequery` CLI tool].
