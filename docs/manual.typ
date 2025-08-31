#import "template.typ" as template: *
#import "/src/lib.typ" as prequery

#import "@preview/crudo:0.1.1"

#show: manual(
  package-meta: toml("/typst.toml").package,
  title: "Prequery",
  subtitle: "Extracting metadata for preprocessing from a typst document, for example image URLs for download from the web.",
  date: datetime(year: 2024, month: 3, day: 19),

  // logo: rect(width: 5cm, height: 5cm),
  abstract: [
    Typst compilations are sandboxed: it is not possible for Typst packages or documents to access the "outside world". This sandboxing has good reasons, but as a consequence certain tasks require more manual work than one may like. For example, if you want to embed an image from the internet in your document, you need to download the image using its URL, save the image in your Typst project, and then show that file using the `image()` function. Prequery offers a limited interface that makes it easier to automate tasks of this kind.
  ],

  scope: (prequery: prequery),
)

= Introduction

Typst compilations are sandboxed: it is not possible for Typst packages, or even just a Typst document itself, to access the "outside world". The only inputs that a Typst document can read are files within the compilation root, and strings given on the command line via `--input`. For example, if you want to embed an image from the internet in your document, you need to download the image using its URL, save the image in your Typst project, and then show that file using the `image()` function. Within your document, the image is not linked to its URL; that step was something _you_ had to do, and have to do for every image you want to use from the internet.

This sandboxing of Typst has good reasons. Yet, it is often convenient to trade a bit of security for convenience by weakening it. Prequery helps with that by providing some simple scaffolding for supporting preprocessing of documents. The process is roughly like that:

+ You start authoring a document without all the external data ready, but specify in the document which data you will need. (With an image for example, you'd use Prequery's #ref-fn("image()") instead of the built-in one to specify not only the file path but also the URL.)
+ Using `typst query`, you extract a list of everything that's necessary from the document. (For images, the command is given in #ref-fn("image()")'s documentation.)
+ You run an external tool (a preprocessor) that is not subject to Typst's sandboxing to gather all the data into the expected places. (There is a _not very well implemented_ Python script for image download in the gallery. For now, treat it as an example and not part of this package's feature set!)
+ Now that the external data is available, you compile the document.

== Fundamental issues and limitations

=== Breaking the sandbox

As mentioned, there's a reason for Typst's sandboxing. Among those reasons are

- *Repeatability:* the content hidden behind URLs on the internet can change, so not having access to them ensures that compiling a document now will have the same result as compiling it later. The same goes for any other nondeterministic thing a preprocessor might do.
- *Security and trust:* when compiling a document, you know what data it can access, so you can fearlessly compile documents you did not write yourself. This is especially important as documents can import third-party packages. You don't need to trust all those packages to be able to trust a document itself.

The sandboxing is something that Typst ensures, but the preprocessors mentioned in step 3 above will necessarily _not_ do the same. So using prequery (in the intended way, i.e. utilizing external preprocessing tools) means

- *you need to trust the preprocessors that you run, because they are not (necessarily) sandboxed,* and
- *you need to trust the documents that you compile, including the packages they use, because the documents provide data to the preprocessors, possibly instructing them to do something that you don't want.*

This doesn't mean that using Prequery is necessarily dangerous; it just has more risks than Typst alone.

=== Compatibility

The preprocessors you use will not necessarily work on all machines where Typst runs, including the wep app. This package assumes that you are using Typst via the command line.

#pagebreak(weak: true)

= Usage

With that out of the way, here's an example of how to use Prequery:

#{
  let example = raw(block: true, lang: "typ", read("/gallery/test.typ").trim())
  example = crudo.lines(example, "5-")
  example
}

Instead of the built-in `image()`, we're using this package's #ref-fn("image()"). That function does the following things:
- it emits metadata to the document that can be queried for the use of preprocessors;
- it "normally" displays the image (note that this fails if the image has not been downloaded yet);
- in "fallback mode" (i.e. "not normally"), it doesn't try to load the image so that compilation succeeds;
- it is implemented on top of the #ref-fn("prequery()") function to achieve these easily.

We call a function of this sort "a prequery", and the image prequery is just a very common example. Other prequeries could, for example, instruct a preprocessor to capture the result of software that can't be run as a #link("https://typst.app/docs/reference/foundations/plugin/")[plugin].

As mentioned, this file will fail to compile unless activating fallback mode as described in the commented out part of the example. The next step is thus to actually get the referenced files, using `query`:

```sh
typst query main.typ '<web-resource>' --field value \
    --input prequery-fallback=true
```

This will output the following piece of JSON:

```json
[{"url": "https://raw.githubusercontent.com/typst-community/prequery/refs/heads/main/test-assets/example-image.svg", "path": "assets/example-image.svg"}]
```

... which can then be fed into a preprocessor. As mentioned, the gallery contains a Python script for processing this query output:

#{
  let example = raw(block: true, lang: "py", read("/gallery/download-web-resources.py").trim())
  // example = crudo.filter(example, l => l != "" and not l.starts-with(regex("\s*#")))
  example
}

I repeat: I *don't* consider this script production ready! I have made the minimal effort of not downloading existing files multiple times, but files are only downloaded sequentially, and can be saved _anywhere_ on the file system, not just where your Typst project can read them. This script is mainly for demonstration purposes. Handle with care!

Assuming Linux and a working Python installation, the query output can be directly fed into this script:

```sh
typst query main.typ '<web-resource>' --field value \
    --input prequery-fallback=true | python3 download-web-resources.py
```

The first time this runs, the image will be downloaded with the following output:

```
assets/example-image.svg: downloading https://raw.githubusercontent.com/typst-community/prequery/refs/heads/main/test-assets/example-image.svg
```

Success! After running this, compiling the document will succeed.

= Authoring a prequery

This package is not just meant for people who want to download images; its real purpose is to make it easy to create _any_ kind of preprocessing for Typst documents, without having to leave the document for configuring that preprocessing. While the package does not actually contain a lot of code, describing how the #ref-fn("image()") prequery is implemented might help -- especially because it relies on a peculiar behavior regarding file path resolution. Here is the actual code:

#{
  let example = raw(block: true, lang: "typ", read("/src/lib.typ").trim())
  codly.codly(ranges: ((85, 85), (88, 88), (91, 94), (99, none)))
  example
}

This function shadows a built-in one, which is of course not technically necessary. It does require us to call the original function by prefixing the `std` module, though. The Parameters to the used #ref-fn("prequery()") function are as follows: the first two parameters specify the metadata made available for querying. The last one is also simple, it just specifies what to display if prequery is in fallback mode: the Unicode character "Frame with Picture" #box(height: 0.65em, move(dy: -0.3em)[\u{1F5BC}]).

The third parameter, written as ```typc _builtin_image.with(..args)``` is the most involved: first of all, this expression is a function that is only called if not in fallback mode. More importantly, `args` is an `arguments` value, and such a value apparently remembers where it was constructed. Compare these two functions (here, `image()` is just the regular, built-in function):

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

With `my-image`, passing `path` to `image()` resolves the path relative to the file `xy/lib.typ`, resulting in `"xy/assets/foo.png"`. With `my-image2` on the other hand, the path seems to be relative to where the `arguments` containing it were constructed, and that happens in `main.typ`, at the call site. The path is thus resolved as `"assets/foo.png"`.

This is of course very useful for prequeries, which are all about specifying the files into which external data should be saved, and then successfully reading from these files! As long as the file name remains in an `arguments` value, it can be passed on and still treated as relative to the caller of the package.

#pagebreak(weak: true)

= Module reference

#module(
  read("/src/lib.typ"),
  name: "prequery",
  label-prefix: none,
)
