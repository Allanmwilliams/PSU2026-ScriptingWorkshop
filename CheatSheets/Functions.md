# Functions

## Quick Reference

| Concept | Syntax |
|---------|--------|
| Declare a function | `function my_func() { }` |
| Call a function | `my_func` |
| Call with arguments | `my_func "arg1" "arg2"` |
| Local variable | `local myVar="value"` |
| Export for child processes | `export MY_VAR="value"` |
| Return a status code | `return 0` |
| Check last return code | `$?` |

---

## Declaring Functions

The `function` keyword is not required, but use it -- it makes your code easier to read and makes functions easy to find with a text search:

```bash
# Recommended -- explicit and searchable
function my_func() {
    echo "Hello."
}

# Also valid -- without the function keyword
my_func() {
    echo "Hello."
}

# Also valid in zsh -- with keyword, without parens
function my_func {
    echo "Hello."
}
```

### Calling Functions

Call a function by name, just like a command. Arguments are passed after the name, separated by spaces (see **Arguments.md** for details on `$1`, `$2`, etc.):

```bash
function greet() {
    echo "Hello, $1."
}

greet "Mac Admins"
# Output: Hello, Mac Admins.
```

---

## Variables: Local vs. Global

By default, variables set inside a function are **global** -- they are visible everywhere in the script. Use `local` to limit a variable's scope to the function it is declared in.

### Without `local` (Global)

```bash
function set_name() {
    name="Mac Admin"
}

set_name
echo "$name"    # Output: Mac Admin -- the variable leaked out
```

### With `local`

```bash
function set_name() {
    local name="Mac Admin"
    echo "$name"    # Output: Mac Admin -- works inside the function
}

set_name
echo "$name"    # Output: (empty) -- not visible outside
```

**Rule of thumb:** Always use `local` for variables inside functions unless you intentionally want them to be global.

---

## Exporting Variables

`export` makes a variable available to **child processes** (commands and scripts launched from your script). Without `export`, child processes cannot see the variable.

> **Tip:** Use `SCREAMING_SNAKE_CASE` for exported variables -- this is the standard convention for environment variables, and it gives readers an immediate visual signal that the variable is intended to cross process boundaries:

```bash
MY_VAR="hello"
export MY_VAR

# Or in one line:
export MY_VAR="hello"
```

This is unrelated to `local` -- they solve different problems:

- `local` controls visibility **within your script** (function scope vs. global scope)
- `export` controls visibility **outside your script** (parent process to child process)

You can combine them:

```bash
function setup_env() {
    export TOOL_PATH="/usr/local/bin:$PATH"   # Global and exported to child processes
    local tempFile="/tmp/scratch.txt"          # Only visible inside this function
}
```

---

## Return Codes

Functions return a status code between 0 and 255. By convention, `0` means success and anything else means failure. This is the same convention used by commands like `grep`, `ping`, etc.

### Setting a Return Code

```bash
function check_file() {
    if [[ -f "$1" ]]; then
        return 0
    else
        return 1
    fi
}
```

### Checking a Return Code

The return code of the last command or function is stored in `$?`:

```bash
check_file "/tmp/myfile"
echo "$?"    # 0 if the file exists, 1 if not
```

### Using Functions Directly in `if` and `&&`

Since functions return a status code, they work anywhere a command does:

```bash
if check_file "/tmp/myfile"; then
    echo "File exists."
fi
```

```bash
check_file "/tmp/myfile" && echo "File exists."
```

### Return vs. Exit

- `return` exits the **function** with a status code
- `exit` exits the **entire script** with a status code

```bash
function my_func() {
    return 1    # Leaves the function, script continues
}

# vs.

function my_func() {
    exit 1      # Terminates the entire script
}
```

---

## Declaring Functions Before Calling Them

Functions must be defined before they are called. The shell reads top to bottom -- if you call a function before its definition, you will get a "command not found" error:

```bash
# This will fail:
greet "Mac Admin"

function greet() {
    echo "Hello, $1."
}
```

```bash
# This works:
function greet() {
    echo "Hello, $1."
}

greet "Mac Admin"
```
