# Sourcing Files

## Quick Reference

| Syntax | Effect |
|--------|--------|
| `source ./file.sh` | Execute `file.sh` in the current shell |
| `. ./file.sh` | Same thing -- `.` is a shorthand for `source` |

> **Compatible with:** bash and zsh -- everything on this page works the same in both.

---

## What Sourcing Does

`source` reads a file and executes its contents in the **current shell**, as if you had typed every line directly into your script. This means any variables, functions, or options set in the sourced file are immediately available -- no subshell, no child process.

This is different from running a script as a command (`./file.sh` or `zsh file.sh`), which launches a new shell process. Variables and functions set in that child process disappear when it exits.

```bash
# Running as a command -- separate process, changes do not persist:
./setup_env.sh
echo "${MY_VAR}"    # Empty -- MY_VAR was set in a child shell that already exited

# Sourcing -- same process, changes persist:
source ./setup_env.sh
echo "${MY_VAR}"    # Has the value set in setup_env.sh
```

---

## Loading a Config File

A common pattern is to keep configuration in a separate file and source it at the top of your script. The config file is just variable assignments:

**config.sh:**
```bash
logDir="/var/log/MyOrgLogs"
logLevel=2
maxRetries=3
targetServer="deploy.example.com"
```

**myscript.sh:**
```bash
#!/bin/zsh --no-rcs

configFile="/path/to/config.sh"

if [[ ! -f "${configFile}" ]]; then
    echo "Config file not found: ${configFile}"
    exit 1
fi

source "${configFile}"

echo "Logging to: ${logDir}"
echo "Max retries: ${maxRetries}"
```

> **Security note:** Sourcing a file executes everything in it. If the file contains `rm -rf /` or `curl ... | sh`, that runs with your script's privileges. Only source files you control or have verified.

---

## Loading a Shared Function Library

For scripts that share common functions (logging, error handling, input validation), put those functions in a library file and source it:

**lib_logging.sh:**
```bash
# Shared logging functions -- source this file, do not run it directly

logFile=""

function log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "${logFile}"
}

function log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "${logFile}"
}
```

**myscript.sh:**
```bash
#!/bin/zsh --no-rcs

source "$(dirname "$0")/lib_logging.sh"

logFile="/var/log/MyOrgLogs/myscript.log"
mkdir -p "$(dirname "${logFile}")"

log_message "Starting setup..."
log_error "Something went wrong."
```

`$(dirname "$0")` resolves to the directory the script lives in, so the source path works regardless of where the script is called from.

---

## Checking Before Sourcing

Always verify the file exists before sourcing it. A missing source file will either silently do nothing or throw an error depending on the shell and options in effect:

```bash
libFile="/usr/local/lib/myorg/common.sh"

if [[ -f "${libFile}" ]]; then
    source "${libFile}"
else
    echo "Required library not found: ${libFile}"
    exit 1
fi
```

---

## Sourced Files Do Not Need a Shebang

Since sourced files run inside the calling script's shell process, a shebang line has no effect. It is harmless to include one as documentation (to signal which shell the file is written for), but it is not required and will not be used.

---

## `source` vs. `.` (dot)

`.` (a single dot followed by a space) is a shorthand for `source`. You will see it in other people's scripts:

```bash
. ./lib_logging.sh
```

This looks confusing because there are two dots doing different things. The first `.` is the command (meaning `source`). The `./` is the current directory in the file path. It reads as: "source the file `./lib_logging.sh`."

This workshop uses `source` because it is easier to read, easier to search for, and does not get lost in a line of punctuation.
