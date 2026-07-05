# awk, sed, and grep

These are text-processing commands, not shell features. They each take input, do something to it, and produce output. They are often used together in pipelines.

| Tool | Purpose |
|------|---------|
| `grep` | **Find** lines that match a pattern |
| `sed` | **Replace** or delete text within lines |
| `awk` | **Extract** and manipulate fields (columns) from structured text |

> **Compatible with:** bash and zsh -- these are external commands, not shell builtins, so their behavior doesn't depend on which shell calls them.

---

## grep -- Find Lines

`grep` reads input line by line and prints only the lines that match a pattern.

### Basic Usage

```bash
# Find lines containing "error" in a log file
grep "error" /var/log/install.log

# Find lines in command output
system_profiler SPApplicationsDataType | grep -i "chrome"
```

### Useful Flags

| Flag | Effect |
|------|--------|
| `-i` | Case-insensitive matching |
| `-v` | Invert -- print lines that do NOT match |
| `-c` | Count matching lines instead of printing them |
| `-l` | Print only filenames that contain a match |
| `-r` or `-R` | Search recursively through directories |
| `-q` | Quiet -- produce no output, just set the exit code |
| `-E` | Extended regex (same as `egrep`) |

### Common Patterns

```bash
# Filter out system accounts (lines starting with _)
dscl . -list /Users | grep -v '^_'

# Check if a process is running (discard output, just use the exit code)
if pgrep -x "Finder" >/dev/null; then
    echo "Finder is running."
fi

# Count how many .pkg files are in a directory
ls /path/to/packages/ | grep -c '\.pkg$'
```

### Fixed Strings with `-F`

If your search term contains regex special characters and you want a literal match, use `-F`:

```bash
# Without -F, the dot matches any character
grep "com.apple.Safari" /some/file

# With -F, the dots are literal
grep -F "com.apple.Safari" /some/file
```

---

## sed -- Replace and Delete Text

`sed` reads input line by line, applies transformations, and prints the result. The most common use is find-and-replace.

### Find and Replace

The basic form is `s/find/replace/`:

```bash
# Replace first occurrence on each line
echo "Hello World" | sed 's/World/Mac Admin/'
# Output: Hello Mac Admin

# Replace ALL occurrences on each line (g = global)
echo "one two one two" | sed 's/one/1/g'
# Output: 1 two 1 two
```

### Editing Files

`-i ''` edits a file in place. The `''` is required on macOS -- it tells `sed` not to create a backup:

```bash
# Replace a value in a config file
sed -i '' 's/logLevel=1/logLevel=3/' /tmp/config.txt
```

> **Note:** On Linux, `sed -i` works without the empty string argument. On macOS (BSD sed), `sed -i ''` is required. This is a common cross-platform gotcha.

### Deleting Lines

```bash
# Delete lines containing "DEBUG"
sed '/DEBUG/d' /var/log/myscript.log

# Delete blank lines
sed '/^$/d' /tmp/output.txt

# Delete comment lines (starting with #)
sed '/^#/d' /tmp/config.txt
```

### Printing Specific Lines

```bash
# Print only line 5
sed -n '5p' /tmp/output.txt

# Print lines 10 through 20
sed -n '10,20p' /tmp/output.txt
```

`-n` suppresses default output. `p` prints the matched lines. Without `-n`, you would get every line printed twice (once by default, once by `p`).

---

## awk -- Extract and Process Fields

`awk` splits each line into fields (columns) separated by whitespace. Fields are numbered starting at `$1`. `$0` is the entire line.

### Extracting Columns

```bash
# Print the second column of each line
awk '{ print $2 }' /tmp/output.txt

# Print the PID (column 2) of running processes
ps aux | awk '{ print $2 }'
```

### Filtering and Extracting

`awk` can filter lines and extract fields in a single step:

```bash
# Print the name of processes using more than 100MB of memory (column 6)
ps aux | awk '$6 > 102400 { print $11 }'

# Pull the serial number from system_profiler
system_profiler SPHardwareDataType | awk '/Serial/ { print $4 }'
```

The pattern before `{ }` is a condition. The block only runs on lines where the condition is true.

### Custom Field Separator with `-F`

By default, `awk` splits on whitespace. Use `-F` to split on something else:

```bash
# Split on colon (like /etc/passwd format)
echo "admin:*:501:20:Admin User:/Users/admin:/bin/zsh" | awk -F: '{ print $1, $5 }'
# Output: admin Admin User

# Split on comma (CSV data)
echo "MacBook Pro,M3,16GB" | awk -F, '{ print $1 }'
# Output: MacBook Pro
```

### Built-in awk Variables

| Variable | Meaning |
|----------|---------|
| `$0` | The entire current line |
| `$1` `$2` ... | First field, second field, etc. |
| `NF` | Number of fields on the current line |
| `NR` | Current line number |

```bash
# Print the last field on each line (useful when column count varies)
awk '{ print $NF }' /tmp/output.txt

# Print line numbers alongside content
awk '{ print NR ": " $0 }' /tmp/output.txt
```

### Formatted Output with printf

`awk` has its own `printf` for formatted output:

```bash
# Print a two-column table with alignment, skipping the first line of output from ps
ps aux | awk 'NR > 1 { printf "%-8s %s\n", $1, $11 }'
```

---

## When to Use Which

**grep** when you just need to find lines. It is the fastest and simplest of the three. If you only need to know whether something is present, or filter input down to relevant lines, reach for `grep` first.

**sed** when you need to change text. Find-and-replace, deleting lines, stripping out patterns. If your task is "take this text and transform parts of it," that is `sed`.

**awk** when you need to work with columns. Extracting specific fields from structured output, doing math on values, filtering by field content. If your task involves "get me column N" or "only print lines where field X meets some condition," that is `awk`.

They combine naturally in pipelines -- `grep` to narrow down the lines, then `awk` or `sed` to transform what is left:

```bash
# Find Chrome in the app list, extract just the version (last field)
system_profiler SPApplicationsDataType | grep -i "chrome" | awk '{ print $NF }'
```

The line between them gets blurry. `awk` can do everything `grep` can (and more). `sed` can do some of what `awk` does. In practice, use the simplest tool that gets the job done.
