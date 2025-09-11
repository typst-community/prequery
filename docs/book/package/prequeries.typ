#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ": book-page, import-spec

#show: book-page.with(title: [Authoring Prequeries])

_Prequery_ is not just meant for people who want to download images; its real purpose is to make it easy to create _any_ kind of preprocessing for Typst documents, without having to leave the document for configuring that preprocessing.

We call the units that provide information to preprocessors outside the document, and process the information given back to the document, prequeries.
The name is a bit overloaded---_Prequery_ is the overall project and a Typst package, `prequery` is a command line tool, and "a prequery" is a kind of Typst function---but it's ultimately simpler than using different names for these related units.

= The `image()` prequery

While the package does not actually contain a lot of code, describing how the `image()` prequery is implemented might help---especially because it relies on a peculiar behavior regarding file path resolution.
Here is the actual code:

#crudo.lines(
  raw(block: true, lang: "typ", read("/src/lib.typ").trim()),
  "85, 88, 91-94, 99-",
)

// #{
//   let example = raw(block: true, lang: "typ", read("/src/lib.typ").trim())
//   codly.codly(ranges: ((85, 85), (88, 88), (91, 94), (99, none)))
//   example
// }

This function shadows a built-in one, which is of course not technically necessary.
It does require us to call the original function by prefixing the `std` module, though.
The Parameters to the used `prequery()` function are as follows:

- The first two parameters specify the metadata made available for querying:
  the value, a dictionary with keys `url` and `path`, will be put into a #link("https://typst.app/docs/reference/introspection/metadata/")[`metadata`] element with label `<web-resource>`.
- The last one is also simple, it just specifies what to display if prequery is in fallback mode:
  the Unicode character "Frame with Picture" \u{1F5BC}.
- The third parameter, written as ```typc std.image.with(..args)``` is the most involved and warrants its own section.

== Using `arguments` to access user paths

If you looked very closely, you may have spotted something strange in one of the previous examples:

#crudo.map(
  ```typ
  #import "PACKAGE_IMPORT": image

  #image("https://example.com/example.png", "example.png")
  ```,
  l => l.replace("PACKAGE_IMPORT", import-spec()),
)

The `image()` function is part of a package, but the path `example.png` refers to a file in a user's document.
#link("https://staging.typst.app/docs/reference/syntax/#paths-and-packages")[Packages can't read users' files], what's happening here?

The answer lies in a peculiarity of Typst's #link("https://typst.app/docs/reference/foundations/arguments/")[`arguments`] type.
When you forward an `arguments` value as a whole to another function, it remembers where the contained individual values came from.

Consider these two similar functions:

```typ
// xy/lib.typ
#let my-image(path, ..args) = image(path, ..args)
#let my-image2(..args) = image(..args)
```

While they seem to be equivalent (the `path` parameter of `image()` is mandatory anyway), they behave differently:

```typ
// main.typ
#import "xy/lib.typ": *
#my-image("assets/foo.png")  // tries to show "xy/assets/foo.png"
#my-image2("assets/foo.png")  // tries to show "assets/foo.png"
```

With `my-image`, passing `path` to `image()` resolves the path relative to the file `xy/lib.typ`, resulting in `"xy/assets/foo.png"`.
With `my-image2` on the other hand, the path is relative to where the `arguments` containing it were constructed, and that happens in `main.typ`, at the call site.
The path is thus resolved as `"assets/foo.png"`.

This is of course very useful for prequeries, which are all about specifying the files into which external data should be saved, and then successfully reading from these files! As long as the file name remains in an `arguments` value, it can be passed on and still treated as relative to the caller of the package.

= Writing your own prequeries

A prequery thus basically consists of the following parts:

- Some metadata, to be read by preprocessors
- Instructions on how to display the preprocessed information, if present
- Some fallback content for when it isn't present
- The logic for deciding when to show the fallback or attempt to display the real content

Your prequery has to provide the first three pieces; the Prequery package ties it together.
As an example, let's attempt to write a prequery that executes a Python script and renders its output.
Using it should look like this:

````typ
#python("out.txt", ```py
print("hello world")
```)
````

The result should be a raw block containing `hello world`, and the fallback also a raw block with `...` in it.

Question 1: what will a preprocessor need to produce the `hello world` result in a form our Typst code can access it?
Well, the code to run, and the file name to save the output to:

````typ
#let python(
  ..args,  // this contains the file path
  code,
) = prequery.prequery(
  (code: code.text, path: args.pos().at(0)),
  <python>,
  // ...
)
````

Question 2: given the file path with the output in it, how can it be displayed?
The answer is to first #link("https://staging.typst.app/docs/reference/data-loading/read/")[`read()`] the file, then put its content into a `raw` element.

And we also know what we want as a fallback:

````typ
#let python(
  ..args,  // this contains the file path
  code,
) = prequery.prequery(
  (code: code.text, path: args.pos().at(0)),
  <python>,
  // a function without parameters, only called if not in fallback mode
  () => {
    let output = read(..args)  // the file path is relative to the caller
    raw(block: true, output)
  },
  // the fallback content, only rendered if in fallback mode
  fallback: [
    ```
    ...
    ```
  ],
)
````

... and that's it!
Granted, this is skipping the more complex part of writing a preprocessor, but for now that is out of scope.
Hopefully, the `prequery` CLI will with time get some useful general purpose preprocessor that could also handle this use case, but right now it requres some tweaking.

== Avoiding individual output files

We started with defining that our prequery would be called like this:

````typ
#python("out.txt", ```py
print("hello world")
```)
````

If you want to use Prequery to create something like an executable notebook, specifying a file name for each code snippet will be pretty distracting.
Better would be something like this:

````typ
#python(```py
print("hello world")
```)
// or even
```pre-py
print("hello world")
```)
````

The bad news is, you _have_ to specify a file name for the read-outside-the-package trick to work;
the good news is, doing it once is enough.
So, let's store the file name in a state, as `arguments`:

````typ
#let python-out-path = state("python-out-path")

#let configure-python(..args) = {
  [#metadata((path: args.pos().at(0)))<python>]
  python-out-path.update(args)
}
````

We're also generating a `metadata` element here that the preprocessor can pick up for output.

All prequeries' results need to be written there, so a plain text file is no longer sufficient.
We could instead use a JSON file containing an array of output strings.

Let's look at how to display the preprocessor results again:
The outputs are in a file.
We need to know what the file name is, and which array element is the correct one.
Each prequery is preceded by its own metadata, and we have also generated one extra `<python>` metadata at the start, so our overall prequery will look like this:

````typ
#let python(code) = prequery.prequery(
  (code: code.text),
  <python>,
  () => {
    // get the file path, as args
    let args = python-out-path.get()
    // get the number of preceding <python> metadata,
    // zero-based and correcting for `configure-python`
    let index = query(selector(<python>).before(here())).len() - 2
    let outputs = json(..args)
    raw(block: true, outputs.at(index))
  },
  fallback: [
    ```
    ...
    ```
  ],
)
````

This lets us call our function as shown above.
For even better results, we can use a show rule:

````typ
#show raw.where(block: true, lang: "pre-py"): set text(1em / 0.8)
#show raw.where(block: true, lang: "pre-py"): python
````

(The first show rule is due to #link("https://github.com/typst/typst/issues/1331")[this issue], which affects content generated by applying a show rule to raw blocks. Note that the font itself is also affected, not just the font _size_, but that doesn't matter in our particular case.)

We now can configure our `python()` prequery once, and then write code to be automatically evaluated with minimal overhead---assuming you have a preprocessor for this purpose, of course.
