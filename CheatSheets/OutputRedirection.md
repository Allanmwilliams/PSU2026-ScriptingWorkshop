# Output Redirection

## Quick Reference

> **Compatible with:** bash and zsh, except `|&`, which requires bash 4.0+ and is not available in macOS's default `/bin/bash` (3.2).

| Syntax | Effect |
|--------|--------|
| `>` | Redirect stdout to a file (overwrite) |
| `>>` | Redirect stdout to a file (append) |
| `2>` | Redirect stderr to a file |
| `&>` | Redirect both stdout and stderr to a file |
| `2>&1` | Redirect stderr to wherever stdout is going |
| `>/dev/null` | Discard stdout |
| `2>/dev/null` | Discard stderr |
| `&>/dev/null` | Discard all output |
| `\|` | Pipe stdout to the next command |
| `\|&` | Pipe both stdout and stderr to the next command |

---

## Stdout to a File

### Overwrite with `>`

Creates the file if it doesn't exist. Overwrites it if it does:

```bash
echo "Hello" > /tmp/output.txt
```

### Append with `>>`

Creates the file if it doesn't exist. Adds to the end if it does:

```bash
echo "Line 1" >> /tmp/output.txt
echo "Line 2" >> /tmp/output.txt
```

---

## Stderr

By default, error messages go to stderr (file descriptor 2), which is separate from normal output (stdout, file descriptor 1). This is why errors still print to the screen even when you redirect output to a file.

### Redirect Stderr to a File

```bash
someCommand 2> /tmp/errors.txt
```

### Redirect Stdout and Stderr to Separate Files

```bash
someCommand > /tmp/output.txt 2> /tmp/errors.txt
```

### Redirect Stderr to Stdout with `2>&1`

Sends stderr to wherever stdout is currently going. Order matters -- put `2>&1` **after** any stdout redirection:

```bash
someCommand > /tmp/all_output.txt 2>&1
```

### Redirect Both with `&>`

Shorthand for sending both stdout and stderr to the same file:

```bash
someCommand &> /tmp/all_output.txt
```

This is equivalent to `someCommand > /tmp/all_output.txt 2>&1` but shorter.

---

## Discarding Output with `/dev/null`

`/dev/null` is a special file that throws away anything written to it.

### Discard Stdout Only

Errors still print to the screen:

```bash
someCommand > /dev/null
```

### Discard Stderr Only

Normal output still prints to the screen:

```bash
someCommand 2> /dev/null
```

### Discard Everything

```bash
someCommand &> /dev/null
```

---

## Pipes

### Basic Pipe with `|`

Sends the stdout of one command to the stdin of the next:

```bash
system_profiler SPApplicationsDataType | grep -i "chrome"
```

### Chaining Multiple Pipes

```bash
dscl . -list /Users | grep -v '^_' | sort
```

### Pipe Both Stdout and Stderr with `|&`

Sends both stdout and stderr to the next command:

```bash
someCommand |& grep "error"
```

