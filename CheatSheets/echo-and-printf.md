# echo and printf

## Quick Reference

| Command | Trailing Newline | Processes `\n` `\t` |
|---------|-----------------|---------------------|
| `echo` (zsh builtin) | Yes | Yes |
| `/bin/echo` (macOS) | Yes | No |
| `printf` | Only if you include `\n` | Yes (in format string) |

---

## `echo` in zsh

zsh has its own builtin `echo` that **does** process escape sequences by default:

```bash
echo "Column1\tColumn2"     # Output: Column1    Column2
echo "Line one\nLine two"   # Output: two separate lines
```

This is different from bash, where `echo` passes `\t` and `\n` through literally unless you use `echo -e`.

### zsh Builtin vs. `/bin/echo`

When you type `echo` in a zsh script, you get zsh's **builtin** `echo`, not `/bin/echo`. They behave differently:

```bash
echo "hello\tworld"          # zsh builtin -- Output: hello    world
/bin/echo "hello\tworld"     # macOS binary -- Output: hello\tworld
```

This almost never matters in practice -- your scripts use the builtin, and that's fine. The only time it becomes relevant is if you explicitly call `/bin/echo` or use `command echo` (which bypasses the builtin and runs the binary).

---

## `printf`

`printf` works like a template. The first argument is the format string, and the remaining arguments get plugged in wherever you put a `%` placeholder.

```bash
printf "%s\t%s\n" "${col1}" "${col2}"
```

This reads as: print a string, then a tab, then a string, then a newline -- filling the two `%s` slots with `col1` and `col2` in order.

### Common Placeholders

| Placeholder | Inserts |
|-------------|---------|
| `%s` | String |
| `%d` | Integer |
| `\n` | Newline |
| `\t` | Tab |

### No Trailing Newline

`printf` does **not** add a trailing newline unless you include `\n` in the format string. This is a feature -- you get exactly what you ask for:

```bash
printf "no newline here"
printf "this starts on the same line\n"
```

This is useful when piping to other commands where a trailing newline would change the output:

```bash
printf '%s' 'SomeExactString' | base64
```

---

## When to Use Which

| Situation | Use |
|-----------|-----|
| Simple messages and log lines | `echo` |
| Output that mixes variables with tabs or newlines | Either works in zsh -- `echo` handles escapes, `printf` gives more control |
| Piping a string with no trailing newline | `printf %s` |
| Cross-shell scripts that must behave the same in bash and zsh | `printf` (consistent behavior everywhere) |
