# Conditionals

## Quick Reference

| Operator | Meaning |
|----------|---------|
| `&&` | Run next command only if previous succeeded |
| `\|\|` | Run next command only if previous failed |
| `;` | Run next command regardless |

---

## Command Chains

These let you run multiple commands on a single line, with control over what happens when a command succeeds or fails.

### `&&` -- Run If Previous Succeeded

The second command only runs if the first exits with status 0 (success):

```bash
mkdir -p "/tmp/mydir" && echo "Directory created."
```

### `||` -- Run If Previous Failed

The second command only runs if the first exits with a non-zero status (failure):

```bash
mkdir -p "/tmp/mydir" || echo "Failed to create directory."
```

### Combining `&&` and `||`

A common pattern for success/failure messages. Read left to right -- `&&` binds to the command before it, `||` catches failure of the whole left side:

```bash
ping -c 1 -t 2 google.com &>/dev/null && echo "Network up." || echo "Network down."
```

### `;` -- Run Regardless

The second command runs no matter what the first one did:

```bash
echo "Starting..."; someCommand; echo "Finished."
```

### Using Tests in Command Chains

Since tests return 0 or 1, they work naturally with `&&` and `||` (see **Tests.md** for all available test flags):

```bash
[[ -d "$targetDir" ]] && echo "Directory exists."
[[ -z "$someVar" ]] && echo "Variable is empty."
[[ ! -f "/tmp/lockfile" ]] || echo "Lockfile exists."
```

---

## `if` / `else` / `elif`

### Basic `if`

```bash
if [[ -f "/tmp/setup_complete" ]]; then
    echo "Setup is done."
fi
```

### `if` / `else`

```bash
if [[ -d "$targetDir" ]]; then
    echo "Directory exists."
else
    echo "Directory not found."
fi
```

### `if` / `elif` / `else`

```bash
# majorOSVersion is the integer major version (e.g. 26), not the full "26.0"
if [[ "$majorOSVersion" -ge 26 ]]; then
    echo "macOS Tahoe or newer."
elif [[ "$majorOSVersion" -ge 15 ]]; then
    echo "macOS Sequoia."
elif [[ "$majorOSVersion" -ge 14 ]]; then
    echo "macOS Sonoma."
else
    echo "Older than Sonoma."
fi
```

### `if` with Command Exit Status

`if` doesn't require `[[ ]]` or `[ ]` -- it just checks whether the command returns 0. Any command works:

```bash
if ping -c 1 -t 2 google.com &>/dev/null; then
    echo "Network is up."
else
    echo "Network is down."
fi
```

```bash
if pgrep -x "Finder" >/dev/null; then
    echo "Finder is running."
fi
```

### Combining Conditions in `if`

```bash
if [[ -f "$configFile" && -r "$configFile" ]]; then
    echo "Config file exists and is readable."
fi
```

```bash
if [[ "$status" == "error" ]] || [[ "$retries" -ge "$maxRetries" ]]; then
    echo "Giving up."
fi
```
