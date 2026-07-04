# Variables and Arrays

## Quick Reference -- Variables

| Syntax | Result |
|--------|--------|
| `myVar="hello"` | Assign a string |
| `myVar="$(someCommand)"` | Assign command output |
| `${#myVar}` | Length of string |
| `${myVar:-default}` | Use `default` if `myVar` is empty/unset |
| `${myVar:=default}` | Set `myVar` to `default` if empty/unset |

## Quick Reference -- String Operations

Given `myVar="backup.2024.tar.gz"`:

| Syntax | Result | Plain English |
|--------|--------|---------------|
| `${myVar#*.}` | `2024.tar.gz` | Remove up to the **first** `.` from the left |
| `${myVar##*.}` | `gz` | Remove up to the **last** `.` from the left |
| `${myVar%.*}` | `backup.2024.tar` | Remove from the **last** `.` to the end |
| `${myVar%%.*}` | `backup` | Remove from the **first** `.` to the end |
| `${myVar/old/new}` | | Replace first match |
| `${myVar//old/new}` | | Replace all matches |

## Quick Reference -- Arrays

| Syntax | Result |
|--------|--------|
| `myArray=(a b c)` | Declare an array |
| `${myArray[@]}` | All elements, as separate words |
| `${myArray[*]}` | All elements, joined into a single word |
| `${myArray[1]}` | First element **(zsh is 1-indexed)** |
| `${#myArray[@]}` | Number of elements |
| `myArray+=("new")` | Append an element |

## Quick Reference -- Special Variables

| Variable | Meaning |
|----------|---------|
| `$?` | Exit code of the last command |
| `$$` | Process ID of the current script |
| `$!` | Process ID of the last background command |
| `$0` | Name of the current script |
| `$#` | Number of arguments passed to the script or function |
| `$@` | All arguments as separate words |
| `$_` | Last argument of the previous command |

---

## Variables

### Assignment

No spaces around `=`. This is a common mistake -- spaces will cause an error:

```bash
# Correct:
myVar="hello"

# Wrong -- the shell reads this as a command called "myVar" with arguments:
myVar = "hello"
```

### Command Substitution

Capture the output of a command into a variable with `"$()"`:

```bash
serialNumber="$(system_profiler SPHardwareDataType 2>&1 | awk '/Serial/ {print $4}')"
osVersion="$(sw_vers -productVersion)"
hostName="$(scutil --get ComputerName)"
```

---

## Default Values

Provide a fallback when a variable might be empty or unset:

### `${var:-default}` -- Use Default

Returns `default` if `var` is empty or unset. Does **not** change `var`:

```bash
logPath="${1:-/var/log/mylog.log}"
echo "Logging to: ${logPath}"
```

### `${var:=default}` -- Set Default

Same as above, but also **assigns** `default` to `var`:

```bash
: "${logPath:=/var/log/mylog.log}"
echo "Logging to: ${logPath}"
```

---

## String Operations

### Length

```bash
myVar="hello"
echo "${#myVar}"    # Output: 5
```

### Substrings

Extract part of a string by offset and length:

```bash
myVar="macOS Sequoia"
echo "${myVar:0:5}"     # Output: macOS
echo "${myVar:6}"       # Output: Sequoia
```

> **zsh note:** Substring indexing with `${var:offset:length}` uses 0-based offsets, even though zsh arrays are 1-based. This matches bash behavior.

### Find and Replace

```bash
myVar="Hello World"
echo "${myVar/World/Mac Admin}"     # Output: Hello Mac Admin   (first match)
echo "${myVar//l/L}"                # Output: HeLLo WorLd       (all matches)
```

### Trimming from the Left

`#` strips from the left, stopping at the first match. `##` strips from the left, matching as far as it can:

```bash
myVar="backup.2024.tar.gz"
echo "${myVar#*.}"      # Output: 2024.tar.gz    (stopped at first .)
echo "${myVar##*.}"     # Output: gz              (matched to last .)
```

### Trimming from the Right

`%` strips from the right, stopping at the first match. `%%` strips from the right, matching as far as it can:

```bash
myVar="backup.2024.tar.gz"
echo "${myVar%.*}"      # Output: backup.2024.tar  (stopped at last .)
echo "${myVar%%.*}"     # Output: backup            (matched to first .)
```

---

## Path Modifiers

> **zsh Only:** These path modifiers do not work in bash -- see the Bash Equivalent column below.

Shortcuts for common file path operations:

| Modifier | Meaning | Bash Equivalent |
|----------|---------|------------------|
| `:h` | Head -- directory path | `${var%/*}` |
| `:t` | Tail -- filename | `${var##*/}` |
| `:r` | Root -- remove extension | `${var%.*}` |
| `:e` | Extension only | (no simple equivalent) |

```bash
filePath="/Users/Shared/backup/config.plist"
echo "${filePath:h}"    # Output: /Users/Shared/backup
echo "${filePath:t}"    # Output: config.plist
echo "${filePath:r}"    # Output: /Users/Shared/backup/config
echo "${filePath:e}"    # Output: plist
```

---

## Arrays

### Declaring an Array

```bash
myArray=("first" "second" "third")
```

Or across multiple lines for readability:

```bash
myArray=(
    "first"
    "second"
    "third"
)
```

### Indexing

**zsh arrays start at 1**, not 0. This is one of the biggest differences from bash:

```bash
myArray=("alpha" "bravo" "charlie")
echo "${myArray[1]}"    # Output: alpha
echo "${myArray[2]}"    # Output: bravo
echo "${myArray[3]}"    # Output: charlie
```

> **In bash**, the same array would start at index 0. Keep this in mind if you work in both shells.

### All Elements

```bash
echo "${myArray[@]}"    # All elements as separate words
```

### Number of Elements

```bash
echo "${#myArray[@]}"   # Output: 3
```

### Appending

```bash
myArray+=("delta")
echo "${myArray[@]}"    # Output: alpha bravo charlie delta
```

### Removing an Element

> **zsh Only:** This array subtraction syntax does not exist in bash.

Remove elements by value using the array subtraction syntax:

```bash
myArray=("alpha" "bravo" "charlie")
myArray=("${(@)myArray:#bravo}")
echo "${myArray[@]}"    # Output: alpha charlie
```

### Slicing

> **zsh Only:** This slicing syntax, combined with zsh's 1-based array indexing, behaves differently than in bash.

Extract a range of elements:

```bash
myArray=("alpha" "bravo" "charlie" "delta" "echo")
echo "${myArray[@]:0:3}"    # Output: alpha bravo charlie   (offset 0 = first element)
echo "${myArray[@]:1:3}"    # Output: bravo charlie delta   (offset 1 = second element)
```

> **zsh note:** Slice offsets are 0-based, even though array indexing is 1-based. This is one of zsh's more confusing gotchas -- `${myArray[1]}` gives you `alpha`, but `${myArray[@]:1:3}` skips `alpha` and starts at `bravo`.

---

## Associative Arrays

> **zsh Only:** Not available in bash 3.2, macOS's default `/bin/bash`.

Key-value pairs instead of ordered elements. Must be declared with `typeset -A` before use:

```bash
typeset -A appVersions

appVersions=(
    [Safari]="18.2"
    [Chrome]="130.0"
    [Firefox]="133.0"
)

echo "${appVersions[Safari]}"      # Output: 18.2
echo "${(k)appVersions[@]}"        # All keys
echo "${(v)appVersions[@]}"        # All values
```

### Looping Over an Associative Array

```bash
for key in "${(k)appVersions[@]}"; do
    echo "${key}: ${appVersions[${key}]}"
done
```
