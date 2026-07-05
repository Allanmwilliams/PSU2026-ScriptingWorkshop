# Exit Codes and Error Handling

## Quick Reference

| Syntax | Effect |
|--------|--------|
| `exit 0` | Exit the script with success |
| `exit 1` | Exit the script with failure |
| `$?` | Exit code of the last command (0 = success) |
| `set -e` | Exit the script immediately if any command fails |
| `set +e` | Stop exiting on command failure |
| `set -o pipefail` | A pipeline fails if any command in it fails |
| `set +o pipefail` | Stop detecting pipeline failures |
| `set -u` | Treat references to unset variables as errors |
| `set +u` | Allow unset variables (default) |
| `trap 'commands' EXIT` | Run cleanup commands when the script exits |

> **Compatible with:** bash and zsh -- every flag and pattern on this page works the same in both.

---

## Exit Codes

Every command returns an exit code between 0 and 255. By convention, `0` means success and anything else means failure.

### Exiting a Script

```bash
exit 0    # Success
exit 1    # Failure
```

If a script ends without an explicit `exit`, it returns the exit code of the last command that ran.

### Checking the Last Exit Code

`$?` holds the exit code of the most recent command:

```bash
someCommand
if [[ $? -ne 0 ]]; then
    echo "someCommand failed."
    exit 1
fi
```

Or more concisely:

```bash
someCommand || { echo "someCommand failed."; exit 1; }
```

---

## `set -e` -- Exit on Error

Tells the shell to exit the script immediately if any command returns a non-zero exit code:

```bash
#!/bin/zsh --no-rcs
set -e

mkdir -p "/tmp/workdir"
cd "/tmp/workdir"
cp "/nonexistent/file" .    # This fails -- script exits here
echo "This never runs."
```

### When `set -e` Does Not Catch Failures

`set -e` ignores failures in commands that are part of a condition:

```bash
set -e

# This does NOT cause an exit, because the command is inside an if:
if grep -q "pattern" /nonexistent/file; then
    echo "Found."
fi

echo "Script continues."
```

It also does not catch failures in the middle of a pipeline (see `set -o pipefail` below).

---

## `set -o pipefail` -- Pipeline Failure Detection

By default, a pipeline returns the exit code of the **last** command only. This means failures earlier in the pipeline are silently ignored:

```bash
# Without pipefail:
badCommand | grep "something"    # Exit code comes from grep, not badCommand
```

`set -o pipefail` makes the pipeline return the exit code of the **last** (rightmost) command that fails:

```bash
#!/bin/zsh --no-rcs
set -e
set -o pipefail

badCommand | grep "something"    # Now the script exits because badCommand failed
```

### Combining `set -e` and `set -o pipefail`

These two are commonly used together at the top of a script:

```bash
#!/bin/zsh --no-rcs
set -e
set -o pipefail
```

This gives you the strongest default error handling: any command failure exits the script, including failures buried inside pipelines.

### Toggling for a Specific Section

Use `set +e` and `set +o pipefail` to turn them off for a section where you expect failures, then turn them back on:

```bash
#!/bin/zsh --no-rcs
set -e
set -o pipefail

# Strict mode for most of the script...

# This command is allowed to fail
set +e
set +o pipefail
someCommand | grep "optional"
result=$?
set -e
set -o pipefail

if [[ $result -ne 0 ]]; then
    echo "Not found, but continuing."
fi
```

---

## A Note on `set -u` and AI-Generated Scripts

LLMs (ChatGPT, Claude, Copilot, etc.) almost always put `set -euo pipefail` at the top of generated scripts. The `-e` and `-o pipefail` parts are covered above. The `-u` flag exits the script whenever an unset variable is referenced -- intended to catch typos like `$taragetHost`. In practice, it also crashes on intentional patterns like checking for optional arguments:

```bash
set -euo pipefail

# Crashes with "parameter not set" before the check runs:
if [[ -z "$1" ]]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi
```

Every optional variable now requires `"${1:-}"` syntax to provide an empty default, and the error messages (`parameter not set`) can send you down the wrong debugging path. When you see `set -euo pipefail` in AI-generated code, consider changing it to `set -eo pipefail`.

---

## `trap` -- Cleanup on Exit

`trap` lets you run commands automatically when the script exits, whether it exits normally, hits an error, or is interrupted. This is essential for scripts that create temporary files, mount disk images, or acquire any resource that needs cleanup.

### Basic Cleanup Pattern

```bash
#!/bin/zsh --no-rcs
set -e
set -o pipefail

tempFile="$(mktemp)"
trap 'rm -f "${tempFile}"' EXIT

# Do work with tempFile...
echo "data" > "${tempFile}"
```

The `rm` command runs no matter how the script exits -- success, failure, or interruption.

### Cleanup Function

For more complex cleanup, use a function:

```bash
#!/bin/zsh --no-rcs
set -e
set -o pipefail

tempDir=""

function cleanup() {
    if [[ -d "${tempDir}" ]]; then
        rm -rf "${tempDir}"
    fi
}
trap cleanup EXIT

tempDir="$(mktemp -d)"
# Do work in tempDir...
```

### Signals

`EXIT` covers all exits, but you can also trap specific signals:

| Signal | When It Fires |
|--------|---------------|
| `EXIT` | Script exits for any reason |
| `INT` | User pressed Ctrl+C |
| `TERM` | Script was killed with `kill` |

```bash
trap cleanup EXIT INT TERM
```

In most cases, `EXIT` alone is sufficient -- it fires regardless of how the script ends.
