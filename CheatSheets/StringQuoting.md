# String Quoting

## Quick Reference

| Syntax | Expansion | Use When |
|--------|-----------|----------|
| `"double quotes"` | Variables and commands are expanded | You need variable/command substitution |
| `'single quotes'` | Nothing is expanded -- everything is literal | You want the exact string, no substitution |
| `$'escape sequences'` | Backslash escapes are processed | You need literal tabs, newlines, or special characters |
| `\` | Escapes the next character | You need one special character treated as literal |

> **Compatible with:** bash and zsh -- every quoting style on this page works the same in both.

---

## Double Quotes

Variables, command substitutions, and arithmetic are expanded inside double quotes. This is what you use most of the time:

```bash
myVar="hello"
echo "The value is: ${myVar}"           # Output: The value is: hello
echo "Today is $(date '+%A')"           # Output: Today is Saturday
echo "Two plus two is $(( 2 + 2 ))"    # Output: Two plus two is 4
```

Double quotes also protect spaces in variables from word splitting:

```bash
filePath="/Users/Shared/My Folder"
ls "$filePath"     # Correct -- treats the path as one argument
ls $filePath       # Wrong -- splits into "/Users/Shared/My" and "Folder"
```

---

## Single Quotes

Nothing is expanded inside single quotes. The string is completely literal:

```bash
echo 'The value is: ${myVar}'     # Output: The value is: ${myVar}
echo 'Today is $(date)'           # Output: Today is $(date)
echo 'Price: $5.00'               # Output: Price: $5.00
```

Use single quotes when the string contains dollar signs, backticks, or other special characters that you don't want the shell to interpret.

### Putting a Single Quote Inside Single Quotes

You can't. A single quote always ends a single-quoted string. The workaround is to end the string, add an escaped single quote, and start a new string:

```bash
echo 'It'\''s a Mac.'    # Output: It's a Mac.
```

This is three pieces joined together: `'It'` + `\'` + `'s a Mac.'`

---

## `$'...'` -- Escape Sequences

`$'...'` processes backslash escape sequences while treating everything else as literal. Use this when you need actual tabs, newlines, or other control characters:

| Escape | Character |
|--------|-----------|
| `\n` | Newline |
| `\t` | Tab |
| `\\` | Literal backslash |
| `\'` | Literal single quote |

```bash
echo $'Column1\tColumn2\tColumn3'
# Output: Column1    Column2    Column3

echo $'Line one\nLine two'
# Output:
# Line one
# Line two
```

Unlike single quotes, `$'...'` does not expand variables:

```bash
echo $'Value: ${myVar}'    # Output: Value: ${myVar}
```

---

## Backslash Escaping

Outside of quotes, a backslash makes the next character literal:

```bash
echo The price is \$5.00    # Output: The price is $5.00
echo Hello\ World           # Output: Hello World (space is preserved, no word split)
```

Inside double quotes, backslash only escapes `$`, `` ` ``, `"`, `\`, and newlines. Everything else is kept literally:

```bash
echo "The price is \$5.00"    # Output: The price is $5.00
echo "A backslash: \\"        # Output: A backslash: \
echo "Not special: \n"        # Output in bash: Not special: \n
                                 # Output in zsh:  Not special: (followed by a newline)
                                 # See echo-and-printf.md for why
```

---

## When to Use Which

| Situation | Use |
|-----------|-----|
| Strings containing variables or commands | `"double quotes"` |
| Strings that should not be interpreted at all | `'single quotes'` |
| Strings with dollar signs you want to keep literal | `'single quotes'` |
| Strings needing real tabs or newlines | `$'escape sequences'` |
| One special character in an otherwise unquoted context | `\backslash` |
