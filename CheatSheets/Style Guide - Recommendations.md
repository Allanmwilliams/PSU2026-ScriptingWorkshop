# Style Guide - Recommendations

Conventions used in this workshop. Not universal rules -- just consistent choices to keep our code readable and safe.

---

## Naming Conventions

| Thing | Style | Example |
|-------|-------|---------|
| Variables and arrays | `camelCase` | `targetHost`, `localUsers` |
| Functions | `snake_case` | `check_file`, `setup_env` |
| Environment variables (exported) | `SCREAMING_SNAKE_CASE` | `TOOL_PATH`, `MY_VAR` |

---

## Shebang

Always start scripts with a shebang line. Use `--no-rcs` to prevent zsh from loading the user's `.zshrc`, `.zprofile`, and other startup files:

```bash
#!/bin/zsh --no-rcs
```

This matters for scripts that run as root or with elevated privileges. Without `--no-rcs`, zsh will source the startup files of whatever user account the script runs under. A user could put arbitrary commands in their `.zshrc` and have them execute with root privileges when your script runs. `--no-rcs` ensures a clean, predictable shell environment every time.

---

## Declaring Functions

Use the `function` keyword. It is not required, but it makes functions easy to spot and easy to search for:

```bash
function do_something() {
    echo "Hello."
}
```

---

## Array Expansion Syntax

In zsh, `"${myArray}"` expands all elements but joins them into a single string. `"${myArray[@]}"` keeps each element as a separate word. Use the `[@]` syntax -- it preserves individual elements and works in both shells:

```bash
# Recommended -- works in both zsh and bash
echo "${myArray[@]}"

# Avoid -- in bash this silently gives only the first element
echo "${myArray}"
```

---

## Quoting Variables

Always quote your variables. Unquoted variables are subject to word splitting, which will break on spaces and cause unexpected behavior:

```bash
# Do this:
echo "$myVar"
cp "$sourceFile" "$destFile"

# Not this:
echo $myVar
cp $sourceFile $destFile
```

---

## Braces Around Variables

Use `${}` when a variable name is adjacent to other text. Without braces, the shell cannot tell where the variable name ends:

```bash
echo "Backup saved to ${backupDir}/${fileName}_backup.txt"
```

Optional but harmless when the variable stands alone -- `"${myVar}"` and `"$myVar"` both work.

---

## Comments

Comment the **why**, not the **what**. The code already says what it does:

```bash
# Good -- explains why
# Retry loop: DNS can be slow to come up after a network change
while ! host example.com &>/dev/null; do

# Bad -- just restates the code
# Loop while host command fails
while ! host example.com &>/dev/null; do
```

---

## Indentation

Use 4 spaces. Be consistent.
