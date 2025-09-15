#import "@preview/shiroa:0.2.3": *
#import "@preview/crudo:0.1.1"

#import "../book.typ": book-page

#show: book-page.with(title: [Shell])

Executes arbitrary commands on the system.
The working directory of the launched commands is that of the containing `typst.toml` file, i.e. paths in the command are relative to the file the command is specified in.
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
# data passed to commands via stdin is in JSON format
format.stdin = "json"
# data received for commands via stdout is in JSON format
format.stdout = "json"
# data written to files for prequeries to read is in JSON format
format.stdout = "json"
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

Currently, all input and output with the executed commands happens through stdin and stdout, either in the form of a single JSON value, or as plain text.
For example, if your document contains these metadata elements:

```typ
#metadata((path: "file1.json", data: "any value"))<shell>
#metadata((path: "file2.json", data: ("complex", "value", 2)))<shell>
```

Then two commands will be executed, and they will receive the following data (respectively) on stdin:

```json
"any value"
["complex","value",2]
```

If there are complex values in the document, then a structured format (i.e. JSON) must be used.
If the document contained only the first value (i.e. only strings), then setting `format.stdin = "plain"` could be used.
In that case, the value passed to the command via stdin would be this:

```txt
any value
```

Similarly, commands must by default return a JSON value via stdout.
By setting `format.stdout = "plain"`, the command output will instead be interpreted as a UTF8 encoded string.

= Output file format

Like for commands, the file format used to save results for prequeries to read can also be set.
By default, all data is saved in JSON format.
That means, for example, that if a command returned `"plain"` text, this result will be quoted in the output file.

If the commands return text (either by setting `format.stdout = "plain"`, or because the produced JSON value was a string), _and_ each command's output is saved in a separate file, then `format.output = "plain"` can be used to store results as plain text file.
If command outputs are saved in a combined file this is not possible, as the file will store an array of results.

= Joined command execution

When `joined = true` is configured, then instead of running one command for each input, one command is run for the combined input instead.
The data will be given to the command as a single JSON array, and `"plain"` input/output is consequently not possible.
For the above document, that would look like this:

```json
["any value",["complex","value",2]]
```

In this mode, the command is required to return a JSON array of the same length.

= Examples

== Running independent Python snippets

To run individual Python code snippets, you can feed Python scripts directly via stdin into a `python` command.
The `python` command expects and produces plain text, not JSON, so it would be configured like this:

```toml
query.selector = "<python>"

command = "python"
format.stdin = "plain"
format.stdout = "plain"
```

You can optionally configure `format.output = "plain"` if you don't want to decode JSON files on the Typst side.

Your Typst document would contain the code snippets in the following form:

````typ
// if you want plain text, you'd need to configure
// individual output files for each snippet
#metadata((path: "out.json"))<python>

#metadata((data: ```py
print("Hello World")
```.text))<python>

#metadata((data: ```py
print("Hello Prequery")
```.text))<python>
````

To specify the code snippets and read the results in a single step, you'd define a #cross-link("/package/prequeries.typ")[custom prequery] that additionally reads the `out.json` file.

== Example: running dependent Python snippets

Let's say you want to create an interactive Python notebook in which later code blocks can depend on earlier ones' results.
Similar to before, your document could look like this:

````typ
#metadata((path: "out.json"))<python>

#metadata((data: ```py
x = 1
print(x)
```.text))<python>

#metadata((data: ```py
y = x + 1
print(y)
```.text))<python>
````

This is a case where we want to use `joined = true`: all snippets should execute in a single Python process.
We'll need to write a Python script to facilitate this, and that script will need to read and write JSON, as required for `joined` commands.

The preprocessor configuration looks like this:

```toml
query.selector = "<python>"

command = ["python", "exec.py"]
joined = true
```

The following Python script, saved as `exec.py` can do the job of executing the code snippets and separately capturing their outputs:

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
