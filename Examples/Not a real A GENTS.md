# AGENTS.MD — Jamf Pro Script Standards & Agent Context

## Core Principles

Always follow these rules exactly — **no shortcuts, no freelancing**. You are an engineer with zero tolerance for sloppiness.
Before *and after* editing a file, **re-read this document** to ensure compliance.

### 1. Reliability Above All

* Scripts must function fleet-wide under **Jamf Pro execution context** (root, non-interactive).
* Never assume GUI access or user input.
* Always handle null returns, network loss, or missing dependencies gracefully.

### 2. Code Reuse

Use shared, reusable components whenever possible — especially for:

* Logging
* Active user detection
* Error handling
* Output formatting (`<result>…</result>` for Extension Attributes)
* Environment validation

---

## Standard Script Template

Every new script starts with this boilerplate for **Jamf Pro-safe execution**:

```zsh
#!/bin/zsh --no-rcs
# Description: <Insert purpose here>
# Author: ep-jamf-scripts Engineering
# Created: $(date +%Y-%m-%d)
# Version: 1.0
# Compatibility: macOS 12+

#######################################
# Utility Functions (Reusable Library)
#######################################

# Logging (write to both stdout and Jamf policy logs)
log() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message"
}

# Active user detection (Jamf-safe)
getActiveUser() {
    local user
    user=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ { if ($3 != "loginwindow") print $3 }')
    echo "${user:-none}"
}

# Validate root execution
requireRoot() {
    if [[ $EUID -ne 0 ]]; then
        log "ERROR: Script must be run as root (Jamf context)."
        exit 1
    fi
}

# Safe <result> output for Extension Attributes
jamfResult() {
    local value="$1"
    if [[ -z "$value" ]]; then
        echo "<result>N/A</result>"
    else
        echo "<result>$value</result>"
    fi
}

#######################################
# Main Execution Logic
#######################################
main() {
    requireRoot
    local currentUser
    currentUser=$(getActiveUser)

    log "Running script as root for active user: ${currentUser}"

    # === Your script logic here ===

    jamfResult "Success"
}

main "$@"
```

---

## Repository Organization

Follow the repo structure strictly:

| Directory                    | Purpose                                              |
| ---------------------------- | ---------------------------------------------------- |
|                              |                                                      |

---

## Code Style & Standards

### Shell

* Use `zsh` for all new scripts.
* Mandatory shebang:

  ```zsh
  #!/bin/zsh --no-rcs
  ```
* Use `camelCase` for variables.
* Use **4 spaces** for indentation.
* No `#######` or decorative comment lines.
* Include clear header metadata (description, author, version).

### `.editorconfig`

```ini
[*]
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{sh,bash,zsh}]
indent_style = space
indent_size = 4
```

---

## Error Handling & Edge Cases

* **Null values**: Always substitute `<result>N/A</result>` or `"none"`.
* **Network failures**: Retry where appropriate; fail gracefully otherwise.
* **Missing binaries**: Check existence with `command -v <binary>` before execution.
* **User context**: Don’t assume `$HOME`; resolve with:

  ```zsh
  currentUser=$(getActiveUser)
  userHome=$(dscl . -read /Users/$currentUser NFSHomeDirectory 2>/dev/null | awk '{print $2}')
  ```

## Success Criteria

When you succeed at your tasks you will mention any hidden gotchas, edge cases we aren't considering, how important those actually are and how to fix, and so on in bullet point form.

## Quality Standards

- Every script must be tested and bulletproof
- Consider fleet-wide deployment scenarios
- Account for network conditions, user permissions, and system variations
- Provide clear error handling and logging
- Never assume user interaction or GUI availability
- Always validate inputs and system state before proceeding
- Consider rollback scenarios for configuration changes

---

## Review Checklist (Before Commit)

✅ Script uses reusable template functions
✅ No references to `~` or `$HOME`
✅ All external commands validated with `command -v`
✅ Error handling present for all critical operations
✅ Output formatting matches Jamf Pro requirements
✅ Passes `shellcheck` and `zsh -n` validation

---

## Gotchas & Notes

* **Jamf Context:** Scripts execute as **root**, but often target the **logged-in user** — always check context before making user-specific changes.
* **Plist edits:** Use `defaults` or `PlistBuddy` carefully; backup first for mutable files.
* **Logs:** Jamf captures `stdout` and `stderr`. No need to log to `/var/log` unless persistent logs are required.
