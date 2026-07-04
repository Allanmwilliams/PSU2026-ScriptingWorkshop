# Debugging

## Quick Reference

| Syntax | Effect |
|--------|--------|
| `set -x` | Print each command and its expanded arguments before it runs |
| `set +x` | Stop printing commands |
| `set -v` | Print each line of the script as it is read, before expansion |
| `set +v` | Stop printing raw lines |

> **Compatible with:** bash and zsh -- every flag on this page works the same in both.

---

## `set -x` -- Trace Execution

Prints every command to stderr before running it, showing the actual values after variable expansion. Each traced line is prefixed using `PS4`, whose zsh default is `+%N:%i> ` -- the source name and line number. This is the primary debugging tool for shell scripts.

### Enable for the Entire Script

```bash
#!/bin/zsh --no-rcs
set -x

myVar="hello"
echo "${myVar}"
```

Output (the script name and line numbers come from zsh's default `PS4`):

```
+myscript.zsh:4> myVar=hello
+myscript.zsh:5> echo hello
hello
```

### Enable for a Specific Section

Wrap the section you want to debug with `set -x` and `set +x`:

```bash
#!/bin/zsh --no-rcs

# Normal execution, no debug output
myVar="hello"

# Debug this part
set -x
echo "${myVar}"
set +x

# Back to normal
echo "This line is not traced."
```

---

## `set -v` -- Verbose Mode

Prints each line of the script exactly as written, before any expansion happens. Less useful on its own, but combined with `set -x` you see both the raw line and the expanded result:

```bash
set -vx
echo "${myVar}"
```

Output:

```
echo "${myVar}"
+myscript.zsh:4> echo hello
hello
```

The first line is from `-v` (what you wrote), the second is from `-x` (what ran).

---

## Running a Script in Debug Mode Without Editing It

You can enable tracing from the command line without adding `set -x` to the script:

```bash
zsh -x ./myscript.sh
```

This traces the entire script. Useful for scripts you don't want to modify.
