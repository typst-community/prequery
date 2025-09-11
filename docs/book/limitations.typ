#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "book.typ": book-page, import-spec

#show: book-page.with(title: [Fundamental limitations])

Typst sandboxes your documents, including packages that you probably haven't inspected, and that's a good thing.
By using Prequery (or rather, a preprocessor based on Prequery), you're intentionally breaking this sandbox at your own risk.
Here are some things you should be aware of when using Prequery:

= Breaking the sandbox

As mentioned, there's a reason for Typst's sandboxing. Among those reasons are

- *Repeatability:* the content hidden behind URLs on the internet can change, so not having access to them ensures that compiling a document now will have the same result as compiling it later. The same goes for any other nondeterministic thing a preprocessor might do.
- *Security and trust:* when compiling a document, you know what data it can access, so you can fearlessly compile documents you did not write yourself. This is especially important as documents can import third-party packages. You don't need to trust all those packages to be able to trust a document itself.

The sandboxing is something that Typst ensures, but preprocessors will necessarily _not_ do the same. So using _Prequery_ (in the intended way, i.e. utilizing external preprocessing tools) means

- *you need to trust the preprocessors that you run, because they are not (necessarily) sandboxed,* and
- *you need to trust the documents that you compile, including the packages they use, because the documents provide data to the preprocessors, possibly instructing them to do something that you don't want.*

This doesn't mean that using Prequery is necessarily dangerous; it just has more risks than Typst alone.

= Compatibility

The preprocessors you use will not necessarily work on all machines where Typst runs, including the web app. Prequery assumes that you are using Typst via the command line.
