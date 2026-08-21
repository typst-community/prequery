#let meta = toml("/typst.toml").package
#let import-spec(namespace: "preview") = "@" + namespace + "/" + meta.name + ":" + meta.version
