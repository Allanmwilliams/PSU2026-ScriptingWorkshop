# Arguments

## Quick Reference

| Variable | Meaning |
|----------|---------|
| `$0` | Name of the script. Inside a function, zsh sets it to the function's name |
| `$1` `$2` `$3`... | First, second, third argument, etc. |
| `$@` | All arguments as separate words |
| `$#` | Number of arguments |
| `shift` | Remove the first argument, shifting `$2` into `$1`, `$3` into `$2`, etc. |

---

## Positional Arguments

Arguments are accessed by position using `$1`, `$2`, etc. This works the same way in scripts and functions.

### In a Script

```bash
#!/bin/zsh --no-rcs
# Usage: ./myscript.sh hostname username

targetHost="$1"
targetUser="$2"

echo "Connecting to ${targetUser}@${targetHost}"
```

### In a Function

Inside a function, `$1`, `$2`, etc. refer to the **function's** arguments, not the script's. zsh also sets `$0` to the function's name rather than the script name:

```bash
function greet() {
    local name="$1"
    local greeting="$2"
    echo "${greeting}, ${name}."
}

greet "Mac Admin" "Hello"
# Output: Hello, Mac Admin.
```

> **Bash difference:** Setting `$0` to the function name is zsh-only. In bash, `$0` keeps its script-level value inside a function.

### Checking for Required Arguments

```bash
if [[ -z "$1" ]]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi
```

---

## `shift`

`shift` removes `$1` and slides everything down. `$2` becomes `$1`, `$3` becomes `$2`, and so on. `$#` decreases by 1.

```bash
echo "$1"    # first
shift
echo "$1"    # second (was $2)
shift
echo "$1"    # third (was $3)
```

`shift 2` removes the first two arguments at once.

---

## All Arguments with `$@`

`$@` expands to every argument as separate words. Always quote it as `"$@"` to preserve arguments that contain spaces:

```bash
for arg in "$@"; do
    echo "Argument: ${arg}"
done
```

---

## Named/Flagged Arguments

For scripts that accept flags like `-u username -h hostname`, use a `while`/`case` loop to parse them:

```bash
#!/bin/zsh --no-rcs

# Defaults
verbose=false
targetHost=""
targetUser=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--host)
            targetHost="$2"
            shift 2
            ;;
        -u|--user)
            targetUser="$2"
            shift 2
            ;;
        -v|--verbose)
            verbose=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
```

The key points:

- `while [[ "$#" -gt 0 ]]` loops as long as there are arguments left
- Flags that take a value (like `-h hostname`) use `$2` for the value and `shift 2` to consume both
- Flags that are standalone (like `-v`) just `shift` once
- `*` catches anything unexpected
