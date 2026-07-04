# Loops

## Quick Reference

| Loop Type | Runs When | Use Case |
|-----------|-----------|----------|
| `for ... in` | Once per item in a list | Iterating over files, arrays, command output |
| `while` | Condition is **true** | Retries, polling, reading lines |
| `until` | Condition is **false** | Waiting for a state to become true |

| Keyword | Effect |
|---------|--------|
| `break` | Exit the innermost loop |
| `break N` | Exit N levels of nested loops |
| `continue` | Skip to next iteration of innermost loop |
| `continue N` | Skip to next iteration N levels up |

---

## For Loops

Use this when you want to execute an action on each item in a list.

### For Loop Over a Glob (File Pattern)

```bash
for app in /Applications/*.app; do
    # Note: the glob is intentionally unquoted -- globs do not expand inside quotes
    echo "$app bundle ID: $(defaults read "${app}/Contents/Info.plist" CFBundleIdentifier)"
done
```

> **Tip:** If the glob matches nothing, zsh errors with "no matches found" and the loop never runs (bash instead passes the literal pattern through). For a path that might be empty, `setopt NULL_GLOB` first or check that at least one match exists.

### For Loop Over an Array

```bash
localUsers=(
    jsmith
    agarcia
    ladmin
    kiosk_user
)

for user in "${localUsers[@]}"; do
    echo "Processing user: ${user}"
done
```

### For Loop Over Command Output

```bash
# Intentionally unquoted -- word splitting is needed to iterate over each username
for user in $(dscl . -list /Users | grep -v '^_'); do
    echo "Found user: ${user}"
done
```

> **Watch out:** Default word splitting in `for` loops splits on spaces, tabs, and newlines. If items contain spaces, use a `while read` loop instead (see below).

### For Loop Over a Numeric Range

```bash
# Intentionally unquoted -- brace expansion does not occur inside quotes
for i in {1..5}; do
    echo "Run number ${i}"
done
```

> **Note:** `i` is a conventional single-letter loop counter, but it can be any variable name you want to declare it as -- `count`, `attempt`, and so on.

---

## While Loops

Use `while` when you want to repeat an action **as long as a condition is true**. The loop checks the condition before each iteration -- if the condition is false from the start, the body never executes.

### Basic While Loop

```bash
while [[ ! -f "/tmp/setup_complete" ]]; do
    echo "Waiting..."
    sleep 2
done
echo "Done."
```

### While Loop with a Counter

```bash
maxAttempts=5
attempt=1

while (( attempt <= maxAttempts )); do
    echo "Attempt ${attempt} of ${maxAttempts}"
    # Do something here; break on success
    (( attempt++ ))
    sleep 3
done
```

### Reading Lines from a File

This is the correct way to iterate over lines that may contain spaces. Never use `for line in $(cat file)` for this -- word splitting will break on spaces within lines.

```bash
while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    echo "$line"
done < "/path/to/input.txt"
```

### Reading Lines from Command Output

Pipe command output into a `while` loop. In zsh, unlike bash, the `while` loop in a pipeline runs in the current shell, so variables set inside the loop persist after it finishes.

```bash
someCommand | while IFS= read -r line; do
    echo "$line"
done
```

> **Bash Equivalent:** In bash, the piped `while` loop runs in a subshell. Any variables set inside are lost once the loop ends. If you need those variables afterward in a script that must also run in bash, use process substitution instead (below).

### Reading Command Output with Process Substitution

> **Compatible with:** bash and zsh -- this pattern behaves the same in both.

`< <(command)` feeds command output into the loop from a file descriptor instead of a pipe. This runs the `while` loop in the current shell, so variables set inside persist after the loop -- no subshell caveat to remember.

This also shows reading more than one field per line -- `read` splits each line on whitespace (the default `IFS`) into as many variables as you give it, with the last variable catching everything left over.

```bash
# Read the command at the end of this while loop, line by line
# (dscl . -list /Users UniqueID  -->  each line is: username    uniqueID)
while read -r currentUser currentUID; do
    currentHomeFolder="$(dscl . -read "/Users/${currentUser}" NFSHomeDirectory | cut -d " " -f 2)"
    echo "${currentUser} has UID: ${currentUID} and home folder: ${currentHomeFolder}"
done < <(dscl . -list /Users UniqueID)
```

> **Note:** Process substitution is not POSIX `sh`, but it behaves the same in zsh and bash.

> **What `-r` does:** Without `-r`, `read` treats a backslash as an escape character -- it gets silently consumed, and a trailing backslash tries to continue the line onto the next one. `-r` makes `read` treat backslashes literally. Usernames and UIDs rarely contain backslashes, but always use `-r` as a default habit -- the moment you read something less predictable (file paths, filenames), a bare `read` without `-r` will mangle it.

### Infinite Loop

Use `while true` (or `while :`) for a loop that runs until explicitly broken out of:

```bash
while true; do
    # Do something; break when finished
    sleep 5
done
```

---

## Until Loops

`until` is the inverse of `while`: the loop body executes **as long as the condition is false**, and stops when the condition becomes true.

Functionally, `until <condition>` is equivalent to `while ! <condition>`. Use whichever reads more naturally.

```bash
until [[ -f "/tmp/setup_complete" ]]; do
    echo "Waiting..."
    sleep 5
done
echo "Done."
```

---

## Loop Control

### `break` -- Exit the Loop Early

Immediately stops the innermost loop and continues execution after it:

```bash
for item in "${myArray[@]}"; do
    if [[ "$item" == "target" ]]; then
        echo "Found it."
        break
    fi
done
```

### `continue` -- Skip to the Next Iteration

Skips the rest of the current iteration and moves to the next one:

```bash
for item in "${myArray[@]}"; do
    [[ "$item" == "skip_me" ]] && continue
    echo "$item"
done
```

### `break` and `continue` with Nested Loops

Both accept an optional numeric argument to affect outer loops. `break 2` breaks out of **two** levels of nesting, `continue 2` skips to the next iteration of the **outer** loop. Without the number, they only affect the innermost loop.

```bash
for outer in "${listA[@]}"; do
    for inner in "${listB[@]}"; do
        [[ "$inner" == "skip_outer" ]] && continue 2
        echo "${outer}: ${inner}"
    done
done
```

### `return` -- Not a Loop Keyword, but a Common Mistake

`return` exits a **function**, not a loop. If you use `return` inside a loop that is inside a function, the entire function exits. If you use `return` in a loop at the top level of a script (outside any function), zsh treats it like `exit` and ends the script. Use `break` to exit loops.
