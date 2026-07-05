# Logging

## Quick Reference

| Syntax | Effect |
|--------|--------|
| `echo "message" >> "${logFile}"` | Append a line to a log file |
| `someCommand \| tee -a "${logFile}"` | Write to the screen and a log file |
| `someCommand 2>&1 \| tee -a "${logFile}"` | Write stdout and stderr to the screen and a log file |

> **Compatible with:** bash and zsh, except where noted below.

---

## Recommendations

### Use a Dedicated Log Folder

Keep all log files for your macOS management tools in one dedicated folder rather than scattering them across the filesystem:

```bash
/var/log/MyOrgLogs/
/var/log/MyOrgJamf/
/var/log/PSU2026-ScriptingWorkshop/
```

Create it at the top of your script if it doesn't exist:

```bash
logDir="/var/log/MyOrgLogs"
mkdir -p "${logDir}"
```

### Name Logs After the Script

Set `scriptName` and `scriptVersion` at the top of every script, and use them to build the log file path. This makes it obvious which script produced which log:

```bash
scriptName="MacAdmins_PSU_Workshop_2026"
scriptVersion="1.0"
logDir="/var/log/MyOrgLogs"
logFile="${logDir}/${scriptName}_${scriptVersion}.log"

mkdir -p "${logDir}"
```

> **Tip:** Avoid spaces in `scriptName` -- they make log file paths harder to work with from the command line. Use underscores instead.

> **Note:** `${scriptName}` needs braces here because the variable is directly followed by an underscore. Without braces, `$scriptName_$scriptVersion` would look for a variable called `scriptName_`, which does not exist.

---

## Basic Logging

### Append to a Log File

```bash
echo "Starting setup..." >> "${logFile}"
```

### Log with a Timestamp

```bash
echo "$(date '+%Y-%m-%d %H:%M:%S') Starting setup..." >> "${logFile}"
```

### A Reusable Log Function

Wrap your timestamp and log file path in a function so you don't repeat yourself:

```bash
function log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "${logFile}"
}

log_message "Starting setup..."
log_message "Installing package..."
log_message "Setup complete."
```

Log output:

```
2026-07-08 14:30:01 Starting setup...
2026-07-08 14:30:05 Installing package...
2026-07-08 14:30:12 Setup complete.
```

---

## Writing to the Screen and a Log File with `tee`

`tee` reads from stdin, writes to a file, and passes the output through to the screen. Use `-a` to append instead of overwrite:

```bash
echo "Starting setup..." | tee -a "${logFile}"
```

### Capture Stdout and Stderr

Redirect stderr to stdout first, then pipe to `tee`:

```bash
someCommand 2>&1 | tee -a "${logFile}"
```

### A Log Function That Writes to Both

```bash
function log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "${logFile}"
}
```

---

## Logging an Entire Script

To send all output from an entire script to both the screen and a log file, use `exec` with `tee` at the top:

```bash
#!/bin/zsh --no-rcs

scriptName="MacAdmins_PSU_Workshop_2026"
scriptVersion="1.0"
logDir="/var/log/MyOrgLogs"
logFile="${logDir}/${scriptName}_${scriptVersion}.log"

mkdir -p "${logDir}"
exec > >(tee -a "${logFile}") 2>&1

echo "This goes to the screen and the log file."
echo "So does this."
```

Everything after the `exec` line -- both stdout and stderr -- is captured in the log file and still printed to the screen.

---

## Log Levels

For more control over logging verbosity, define separate functions for each log level and a `logLevel` variable that controls which messages are recorded. Set `logLevel` at the top of your script to control how much detail is logged.

The levels from least to most verbose: `error` (1), `warn` (2), `info` (3). Each level includes all levels above it -- setting `logLevel=2` logs warnings **and** errors, but not info messages.

```bash
#!/bin/zsh --no-rcs

# ------ Configuration ------
# Log levels: 1 = error only, 2 = warn + error, 3 = info + warn + error
logLevel=2
logFile="/var/log/MyOrgLogs/myscript.log"
mkdir -p "$(dirname "${logFile}")"

# ------ Log Functions ------
function log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "${logFile}"
}

function log_warn() {
    if [[ "$logLevel" -ge 2 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [WARN]  $1" | tee -a "${logFile}"
    fi
}

function log_info() {
    if [[ "$logLevel" -ge 3 ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]  $1" | tee -a "${logFile}"
    fi
}

# ------ Usage ------
log_info "Starting setup..."
log_info "Checking prerequisites..."
log_warn "Disk space is below 10GB."
log_error "Package installation failed."
log_info "Cleanup complete."
```

With `logLevel=2`, the output is:

```
2026-07-08 14:30:01 [WARN]  Disk space is below 10GB.
2026-07-08 14:30:01 [ERROR] Package installation failed.
```

With `logLevel=3`, all five messages are logged. With `logLevel=1`, only the error is logged.

---

## Simple Log Rotation

Call this at the top of your script, after `logFile` is set but before any logging starts. If the log file is over the size threshold, it renames the existing log to `.old.log` before your script begins writing:

```bash
function log_rotate() {
    local maxSizeKB=1024
    if [[ -f "${logFile}" ]]; then
        # stat -f '%z' returns file size in bytes (macOS-specific)
        local fileSizeKB=$(( $(stat -f '%z' "${logFile}") / 1024 ))
        if [[ "$fileSizeKB" -ge "$maxSizeKB" ]]; then
            mv "${logFile}" "${logFile:r}.old.log"
            # Note: ${logFile:r} is a zsh path modifier that removes the extension.
            # Bash equivalent: ${logFile%.*}
            touch "${logFile}"
        fi
    fi
}
```

This keeps one rotated backup. Each rotation overwrites the previous `.old.log` -- no pile of numbered archives to manage.

---

## Advanced Log Rotation

Keeps up to 10 rotated logs (`.0.log` through `.9.log`), where `.0.log` is the most recent and `.9.log` is the oldest. When the current log exceeds the size threshold, each existing rotation shifts up by one number and the oldest is discarded:

```bash
function log_rotate() {
    local maxSizeKB=1024
    if [[ -f "${logFile}" ]]; then
        # stat -f '%z' returns file size in bytes (macOS-specific)
        local fileSizeKB=$(( $(stat -f '%z' "${logFile}") / 1024 ))
        if [[ "$fileSizeKB" -ge "$maxSizeKB" ]]; then
            # Remove the oldest log
            rm -f "${logFile:r}.9.log"
            # Note: ${logFile:r} is a zsh path modifier that removes the extension.
            # Bash equivalent: ${logFile%.*}
            # Shift each remaining log up by one number
            for i in {8..0}; do
                if [[ -f "${logFile:r}.${i}.log" ]]; then
                    mv "${logFile:r}.${i}.log" "${logFile:r}.$(( i + 1 )).log"
                fi
            done
            # Move current log to .0.log
            mv "${logFile}" "${logFile:r}.0.log"
            touch "${logFile}"
        fi
    fi
}
```

After several rotations, the log folder looks like:

```
myscript.log          <-- current, actively written to
myscript.0.log        <-- previous rotation (newest)
myscript.1.log
myscript.2.log
...
myscript.9.log        <-- oldest, deleted on next rotation
```
