#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ": book-page

#show: book-page.with(title: [Shell])

Executes arbitrary commands on the system.
// If all command configuration is up-to-date, command execution is skipped.
// This preprocessor can be used in combination with the #link("https://typst.app/universe/package/prequery")[Prequery package's] `shell()` function.

= Configuration & defaults

```toml
[[tool.prequery.jobs]]
name = "..."  # required
kind = "shell"

# the query getting metadata from the document
# see https://typst.app/docs/reference/introspection/query/#command-line-queries
query.selector = "..."  # required
query.field = "value"
query.one = false

command = "..." # required, can also be an array like `["ls" "-l"]`

# execute a single command with an array of all inputs
joined = false
```
// # execute commands concurrently, not in the order they appear in the document
// concurrent = false
// # can be set to `true` or a file name to keep a file with all known resources
// index = false

= Data format required from prequeries

The Shell preprocessor saves all command results into document-defined files.
There are two possible modes:

- All results are stored in individual files.
  For this, all queried values must be dictionaries with keys `path` and `data`, e.g.:

  ```typ
  #metadata((path: "file1.json", data: "any value"))<shell>
  #metadata((path: "file2.json", data: ("complex", "value", 2)))<shell>
  ```
  The `path`s must be strings and readable by the Typst document.
  All queried values must use distinct paths.

- All results are stored in a single file, as a JSON array.
  For this, the first queried value must have a key `path`, followed by values only a `data` key, e.g.:

  ```typ
  #metadata((path: "file.json"))<shell>
  #metadata((data: "any value"))<shell>
  #metadata((data: ("complex", "value", 2)))<shell>
  ```

For the examples above, the following query config would be used:

```toml
query.selector = "<shell>"
query.field = "value"
```

= Command input and output

Currently, all input and output with the executed commands happens through stdin and stdout, in the form of JSON value.
That means that, if your document for contains these metadata elements:

```typ
#metadata((path: "file1.json", data: "any value"))<shell>
#metadata((path: "file2.json", data: ("complex", "value", 2)))<shell>
```

Then two commands will be executed, and they will receive the following data (respectively) on stdin:

```json
"any value"
["complex","value",2]
```

Likewise, the commands are required to return a single valid JSON value through stdout.

= Joined command execution

When `joined = true` is configured, then instead of running one command for each input, one command is run for the combined input instead.
The data will be given to the command as a single JSON array.
For the above document, that would look like this:

```json
["any value",["complex","value",2]]
```

In this mode, the command is required to return a JSON array of the same length.

== Example: running dependent Python snippets

Let's say you want to create an interactive Python notebook in which later code blocks can depend on earlier ones' results.
You could do this with a document like this:

````typ
// put all output in the same file
#metadata((path: "out.json"))<python>
// code block 1
#metadata((data: ```py
x = 1
print(x)
```.text))<python>
// code block 2
#metadata((data: ```py
y = x + 1
print(y)
```.text))<python>
````

Here, the selector for querying the metadata is `query.selector = "<python>"`.
To execute all the code snippets, and separate their outputs, a Python script like the following could be used:

```py
import contextlib
import io
import json
import sys

def run(code, scope):
    # redirect output to a string
    with contextlib.redirect_stdout(io.StringIO()) as f:
        # execute the code snippet, using the given dictionary as the scope
        exec(code, scope)
    return f.getvalue()

# load inputs (JSON array) from stdin
inputs = json.loads(sys.stdin.read())
scope = {}
# run all code snippets in order,
# using the same scope to share "global" variables
outputs = [run(code, scope) for code in inputs]

# write outputs (JSON array of the same length) back to stdout
sys.stdout.write(json.dumps(outputs))
```

If this script is saved as `exec.py`, it could be run through the Shell preprocessor like this:

```toml
query.selector = "<python>"

command = ["python", "exec.py"]
joined = true
```
