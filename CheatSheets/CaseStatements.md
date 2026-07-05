# Case Statements

## Quick Reference

| Syntax | Meaning |
|--------|---------|
| `;;` | Stop here -- do not check any more patterns |
| `;&` | Fall through -- run the next block without checking its pattern |
| `;|` | Continue -- keep checking remaining patterns |
| `\|` | OR -- match multiple patterns for one block |
| `*` | Wildcard -- matches anything (used as default/catch-all) |

---

## Basic Syntax

```bash
case "$someVar" in
    pattern1)
        echo "Matched pattern1."
        ;;
    pattern2)
        echo "Matched pattern2."
        ;;
    *)
        echo "No match found."
        ;;
esac
```

---

## Pattern Matching

### Multiple Patterns with `|` (OR)

```bash
case "$answer" in
    yes|y|Y)
        echo "Accepted."
        ;;
    no|n|N)
        echo "Declined."
        ;;
    *)
        echo "Unknown response."
        ;;
esac
```

### Glob Patterns

Standard glob wildcards work in `case` patterns:

```bash
case "$filename" in
    *.pkg)
        echo "Installer package."
        ;;
    *.dmg)
        echo "Disk image."
        ;;
    *.app)
        echo "Application bundle."
        ;;
    *)
        echo "Unknown file type."
        ;;
esac
```

---

## Terminators

### `;;` -- Stop (Default)

After a match, stop checking patterns. This is the standard behavior:

```bash
case "$color" in
    red)
        echo "Red."
        ;;
    blue)
        echo "Blue."
        ;;
esac
```
> **Note:** This is probably the only Stop type you'll ever need to use in a typical shell script.

### `;&` -- Fall Through

After a match, run the **next block unconditionally** without checking its pattern:

```bash
case "$level" in
    critical)
        echo "Paging on-call."
        ;&
    warning)
        echo "Logging alert."
        ;&
    info)
        echo "Writing to log."
        ;;
esac
# Input "critical" prints all three lines.
# Input "warning" prints the last two.
# Input "info" prints only the last one.
```

### `;|` -- Continue Testing

After a match, **keep checking remaining patterns**. Runs every subsequent block whose pattern also matches:

```bash
case "$input" in
    *.sh)
        echo "Shell script."
        ;|
    test*)
        echo "Starts with test."
        ;|
    *)
        echo "Processing complete."
        ;;
esac
# Input "test_backup.sh" prints all three lines.
# Input "deploy.sh" prints "Shell script." and "Processing complete."
# Input "testfile" prints "Starts with test." and "Processing complete."
```

> **Note:** `;|` is a zsh feature. In bash, the equivalent is `;;&` (double semicolon ampersand).
