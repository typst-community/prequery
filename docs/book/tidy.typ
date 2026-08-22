#import "@preview/tidy:0.4.3"

#import "../man-style.typ"

#let _info = state("manual:info")

// set the package metadata and scope
#let set-info(
  package-meta: none,
  scope: (:),
) = {
  _info.update((
    meta: package-meta,
    scope: scope,
  ))
}

// retrieve the package metadata (contextual)
#let package-meta() = _info.get().meta

#let module(
  code,
  name: none,
  label-prefix: auto,
  scope: (:),
  preamble: "",
  ..args,
) = {
  let (name, label-prefix) = (name, label-prefix)
  if label-prefix == auto and name != none {
    label-prefix = name + "."
  } else if type(label-prefix) == str {
    label-prefix += "."
  } else {
    assert(label-prefix == none or name == none)
    label-prefix = ""
  }
  if name != none {
    name = raw(name)
  }

  context {
    let scope = _info.get().scope + scope
    let module = tidy.parse-module(
      code,
      name: name,
      label-prefix: label-prefix,
      scope: scope,
      preamble: preamble,
    )
    tidy.show-module(
      module,
      show-module-name: name != none,
      sort-functions: none,
      style: man-style,
      show-outline: false,
      ..args,
    )
    // [#module]
  }
}
