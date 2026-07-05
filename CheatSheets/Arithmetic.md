# Arithmetic

## Quick Reference

| Syntax | Effect |
|--------|--------|
| `$(( expression ))` | Evaluate an arithmetic expression and return the result |
| `(( expression ))` | Evaluate an expression; returns 0 (true) if non-zero, 1 (false) if zero |
| `(( var++ ))` | Increment `var` by 1 |
| `(( var-- ))` | Decrement `var` by 1 |
| `(( var += n ))` | Add `n` to `var` |
| `(( var -= n ))` | Subtract `n` from `var` |
| `(( var *= n ))` | Multiply `var` by `n` |
| `(( var /= n ))` | Divide `var` by `n` (integer division, truncates) |
| `(( var % n ))` | Remainder (modulo) |

> **Compatible with:** bash and zsh -- every operator on this page works the same in both.

**Reassigning vs. just computing:** `$(( var -= n ))` evaluates the expression *and permanently updates `var`* in the current shell. The compound assignment operators (`+=`, `-=`, `*=`, `/=`, `%=`, `++`, `--`) always modify the variable when used inside `$(( ))`, whether or not you capture or print the output. `$(( var - n ))` only computes a value -- `var` is left completely unchanged. Both can print the same result, so the difference is easy to miss unless you check the variable afterward:

```bash
n=6 ; var=10
echo "$(( var -= n ))"   # Output: 4  -- and var is now 4
echo "${var}"            # Output: 4
```

```bash
n=6 ; var=10
echo "$(( var - n ))"    # Output: 4  -- but var is untouched
echo "${var}"            # Output: 10
```

---

## `$(( ))` -- Arithmetic Expansion

Evaluates a math expression and returns the result as text. Use this when you need the computed value -- in an assignment, an `echo`, or anywhere you would put a string:

```bash
result=$(( 10 + 3 ))
echo "${result}"    # Output: 13

echo "Total: $(( fileCount + dirCount ))"
```

Variables inside `$(( ))` do not need the `$` prefix:

```bash
width=1920
height=1080
pixels=$(( width * height ))
echo "${pixels}"    # Output: 2073600
```

---

## `(( ))` -- Arithmetic Evaluation

Evaluates the expression but does not return the result as text. Used for two things: modifying variables in place, and as a condition (see **Tests.md** for using `(( ))` in conditionals).

### Modifying Variables

```bash
count=0
(( count++ ))       # count is now 1
(( count += 5 ))    # count is now 6
(( count /= 2 ))    # count is now 3
(( count-- ))       # count is now 2
```

### As a Condition

`(( ))` returns 0 (true) if the expression evaluates to non-zero, and 1 (false) if it evaluates to zero. This makes it work naturally in `if` statements and `while` loops:

```bash
maxAttempts=5
attempt=1

while (( attempt <= maxAttempts )); do
    echo "Attempt ${attempt} of ${maxAttempts}"
    (( attempt++ ))
done
```

---

## Operators

| Operator | Meaning |
|----------|---------|
| `+` `-` `*` | Add, subtract, multiply |
| `/` | Integer division (truncates toward zero) |
| `%` | Remainder (modulo) |
| `**` | Exponentiation |
| `==` `!=` `<` `>` `<=` `>=` | Comparison (returns 1 or 0) |
| `&&` `\|\|` `!` | Logical AND, OR, NOT |

---

## Integer Only

The shell only does integer math. Division truncates -- there are no decimals:

```bash
echo $(( 7 / 2 ))     # Output: 3  (not 3.5)
echo $(( 10 / 3 ))    # Output: 3  (not 3.33)
```

### When You Need Decimals

For floating-point math, use `bc` or `awk`. Both are available on every Mac:

```bash
# bc -- pipe an expression to it
fileSizeGB="$(echo "scale=2; 4831838208 / 1073741824" | bc)"
echo "${fileSizeGB}"    # Output: 4.50

# awk -- useful for one-off calculations
fileSizeGB="$(awk 'BEGIN { printf "%.2f", 4831838208 / 1073741824 }')"
echo "${fileSizeGB}"    # Output: 4.50
```

`scale=2` in `bc` sets the number of decimal places. `%.2f` in `awk` does the same thing via printf formatting.

---

## Practical Patterns

### Converting Units

```bash
# Bytes to megabytes (integer)
fileSizeBytes=52428800
fileSizeMB=$(( fileSizeBytes / 1024 / 1024 ))
echo "${fileSizeMB}MB"    # Output: 50MB
```

### Calculating Percentages

```bash
used=3500
total=5000
# Integer math only -- multiply first to avoid truncating to zero
percent=$(( used * 100 / total ))
echo "${percent}% disk used"    # Output: 70% disk used
```

### Elapsed Time

```bash
startTime="$(date +%s)"

# ... do work ...
sleep 2

endTime="$(date +%s)"
elapsed=$(( endTime - startTime ))
echo "Finished in ${elapsed} seconds."
```
