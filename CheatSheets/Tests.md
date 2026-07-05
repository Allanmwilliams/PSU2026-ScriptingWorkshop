# Tests

## Quick Reference

| Test Flag | True When |
|-----------|-----------|
| `-e` | Path exists (file, directory, symlink, etc.) |
| `-f` | Path exists and is a regular file |
| `-d` | Path exists and is a directory |
| `-s` | File exists and is not empty (size > 0) |
| `-x` | File exists and is executable |
| `-r` | File exists and is readable |
| `-w` | File exists and is writable |
| `-n` | String is not empty (length > 0) |
| `-z` | String is empty (length == 0) |
| `!` | Negates any test |

| Comparison | Meaning | Use With |
|------------|---------|----------|
| `=~` | Regex match | `[[ ]]` |
| `==` | String equals (or glob pattern) | `[[ ]]` |
| `!=` | String not equals | `[[ ]]` |
| `-eq` | Integer equals | `[[ ]]` or `[ ]` |
| `-ne` | Integer not equals | `[[ ]]` or `[ ]` |
| `-lt` | Integer less than | `[[ ]]` or `[ ]` |
| `-gt` | Integer greater than | `[[ ]]` or `[ ]` |
| `-le` | Integer less than or equal | `[[ ]]` or `[ ]` |
| `-ge` | Integer greater than or equal | `[[ ]]` or `[ ]` |

---

## Single Bracket Tests `[ ]`

`[` is actually a command (try `which [` or `man test`). It evaluates an expression and returns 0 for true, 1 for false.

### File Tests

```bash
[ -e "/some/path" ]        # True if path exists (any type)
[ -f "/some/file" ]        # True if it exists and is a regular file
[ -d "/some/directory" ]   # True if it exists and is a directory
[ -x "/some/script.sh" ]   # True if it exists and is executable
[ -s "/some/file" ]        # True if it exists and is not empty
```

### String Tests

```bash
[ -n "$someVar" ]          # True if string is not empty
[ -z "$someVar" ]          # True if string is empty
```

### Negation with `!`

`!` inverts any test:

```bash
[ ! -d "/some/directory" ] # True if directory does NOT exist
[ ! -z "$someVar" ]        # True if string is NOT empty
```

---

## Double Bracket Tests `[[ ]]`

`[[ ]]` is a zsh (and bash) built-in that is safer and more flexible than `[ ]`. Key differences:

- No word splitting on variables, so `"$var"` and `$var` both work (quoting is still good habit)
- Supports `&&` and `||` inside the brackets
- Supports pattern matching with `==`

### String Comparisons

```bash
[[ "$someVar" == "expected" ]]    # String equals
[[ "$someVar" != "unexpected" ]]  # String not equals
[[ -n "$someVar" ]]               # String is not empty
[[ -z "$someVar" ]]               # String is empty
```

### Integer Comparisons

```bash
[[ "$count" -eq 0 ]]    # Equal to
[[ "$count" -ne 0 ]]    # Not equal to
[[ "$count" -lt 10 ]]   # Less than
[[ "$count" -gt 10 ]]   # Greater than
[[ "$count" -le 10 ]]   # Less than or equal to
[[ "$count" -ge 10 ]]   # Greater than or equal to
```

### Combining Conditions Inside `[[ ]]`

```bash
[[ -d "$somePath" && -w "$somePath" ]]           # Directory exists AND is writable
[[ "$status" == "pass" || "$status" == "skip" ]]  # String is "pass" OR "skip"
[[ ! -f "$lockfile" ]]                            # File does NOT exist
```

---

## Arithmetic Conditionals `(( ))`

For integer comparisons, `(( ))` lets you use familiar math operators instead of `-lt`, `-gt`, etc. Returns 0 (true) if the expression is non-zero, 1 (false) if the expression is zero.

```bash
(( count == 0 ))     # Equal to
(( count != 0 ))     # Not equal to
(( count < 10 ))     # Less than
(( count > 10 ))     # Greater than
(( count <= 10 ))    # Less than or equal to
(( count >= 10 ))    # Greater than or equal to
```

> **Note:** Variables inside `(( ))` do not need the `$` prefix. `(( count > 5 ))` and `(( $count > 5 ))` both work.

---

## Regex Matching with `=~`

`[[ "$string" =~ pattern ]]` tests whether the string matches a regular expression. The pattern is an extended regular expression (ERE), the same syntax used by `grep -E`.

### Basic Match

```bash
serialNumber="C02X1234ABCD"

if [[ "$serialNumber" =~ ^C02 ]]; then
    echo "This is a Mac serial number."
fi
```

### Matching Version Strings

```bash
osVersion="$(sw_vers -productVersion)"

if [[ "$osVersion" =~ ^26\. ]]; then
    echo "Running macOS Tahoe."
fi
```

### Capture Groups with `$MATCH` and `$match`

When the regex matches, zsh populates two special variables:

- `$MATCH` -- the entire matched string
- `$match` -- an array of capture group contents (parenthesized groups)

```bash
firmwareVersion="1.2.3-build456"

if [[ "$firmwareVersion" =~ '([0-9]+)\.([0-9]+)\.([0-9]+)' ]]; then
    echo "Full match: ${MATCH}"       # Output: 1.2.3
    echo "Major: ${match[1]}"          # Output: 1
    echo "Minor: ${match[2]}"          # Output: 2
    echo "Patch: ${match[3]}"          # Output: 3
fi
```

> **Bash difference:** Bash uses `${BASH_REMATCH[0]}` for the full match and `${BASH_REMATCH[1]}` etc. for capture groups. The zsh `$MATCH` / `$match` variables do not exist in bash.

### Quoting the Pattern

In zsh, the regex pattern can be quoted or unquoted -- both work. Quoting is safer because it prevents glob characters from being expanded before the regex engine sees them:

```bash
# Both work in zsh:
[[ "$myVar" =~ '[0-9]{3}-[0-9]{4}' ]]    # Quoted -- recommended
[[ "$myVar" =~ [0-9]{3}-[0-9]{4} ]]      # Unquoted -- also works in zsh
```

> **Bash difference:** In bash, quoting the pattern turns off regex interpretation entirely -- it becomes a literal string match. This is one of the bigger cross-shell gotchas with `=~`.
