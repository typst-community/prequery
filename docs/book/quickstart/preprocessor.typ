#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ": book-page

#show: book-page.with(title: [Running the preprocessor])

The goal of _Prequery_ is to avoid manual preparation of external resources before compiling your Typst document.
The Prequery package alone can't achieve that, since it sits inside Typst's sandbox.
This is where Prequery's preprocessor enters the picture.

= Configuring `prequery`

In the #cross-link("/quickstart/documents.typ")[previous section], we have prepared our document to provide the necessary information, now we need to configure the preprocessor to use it.
This is done inside the document's `typst.toml` file:

```toml
[package]
name = "..."
version = "0.0.1"
entrypoint = "..."

[[tool.prequery.jobs]]
name = "download"
kind = "web-resource"
```

The `[package]` part of that file is not used by the preprocessor, but is required by Typst.
Unless your document is part of a package, you can simply copy this part exactly as written, with `...` and all.
This requirement will hopefully be lifted in the future.

The `[[tool.prequery.jobs]]` part can appear multiple times; each one adds one _job_ to the preprocessor, which is executed when running the `prequery` command.
In this case, we're running a `web-resource` job, which downloads files from the web.
The files to download are the ones that were specified in the previous section, by using the `image()` function.
We also give it a name, which is shown in the output for tracking the job's progress.

= Running `prequery`

Let's now actually run the preprocessor:

```bash
prequery main.typ
```

If everything is in place, you should see some output like this:

```
[download] beginning job...
[download] Downloading https://example.com/example.png to example.png...
[download] Downloading https://example.com/example.png to example.png finished
[download] job finished
```

... and that's it!
The image required by your document is now present, and you can compile it:

```bash
typst compile main.typ
```

If you later add images, simply run the `prequery` command again.

= Recap & Next steps

You have now seen how to automate the preparation of you document's resources using Prequery:

- Use the Prequery package to embed information about the required resources into your document.
- Configure the `prequery` command line tool in `typst.toml` to tell it what kind of resources/processing is required.
- Run the `prequery` command whenever your resources have changed.

This is almost the current extent of what _Prequery_ can do.
You can take a look at the #cross-link("/preprocessors/web-resource.typ")[`web-resource` preprocessor's documentation] to see its more advanced features.
If you need to do something other than downloading files from the web, let us know in an issue on #link("https://github.com/typst-community/prequery/issues")[the package] or #link("https://github.com/typst-community/prequery-preprocess/issues")[the CLI tool].
