# Input

## Quick Reference

| Syntax | Effect |
|--------|--------|
| `read myVar` | Read a line of input into `myVar` |
| `read -r myVar` | Read without interpreting backslashes |
| `read -s myVar` | Read without echoing to the screen (passwords) |
| `read "?Prompt: " myVar` | Display a prompt, then read input (zsh) |
| `read -p "Prompt: " myVar` | Display a prompt, then read input (bash) |
| `<<EOF ... EOF` | Here-doc -- feed a block of text as stdin |
| `<<<` | Here-string -- feed a single string as stdin |

---

## `read` -- Reading User Input

`read` pauses the script and waits for the user to type something and press Enter. This is for interactive scripts where a person is sitting at the terminal.

### Basic Read

```bash
echo "Enter your name:"
read userName
echo "Hello, ${userName}."
```

### Read with a Prompt (zsh)

In zsh, the prompt is passed as a `?`-prefixed string to `read`:

```bash
read "userName?Enter your name: "
echo "Hello, ${userName}."
```

> **Bash difference:** Bash uses `read -p "Enter your name: " userName` instead. The `-p` flag does not work for prompts in zsh.

### Read Without Backslash Interpretation

Always use `-r` unless you specifically want backslash escapes to be processed. Without it, `read` treats backslashes as escape characters and strips them:

```bash
read -r filePath
echo "${filePath}"
```

### Read Without Echoing (Passwords)

`-s` suppresses the input on screen. Print a newline after, since `-s` also suppresses the Enter keypress:

```bash
read -s "userPass?Enter password: "
echo ""
echo "Password received."
```

### Read Into Multiple Variables

`read` splits the input on whitespace and assigns each word to a variable. The last variable gets everything remaining:

```bash
echo "Enter first and last name:"
read firstName lastName
echo "First: ${firstName}"
echo "Last: ${lastName}"
```

---

## Here-Docs

A here-doc feeds a block of text to a command's stdin. The block starts with `<<LABEL` and ends when `LABEL` appears alone on a line. The label can be any word -- `EOF` is conventional:

```bash
cat <<EOF
Hello, ${userName}.
Today is $(date '+%A').
EOF
```

Variables and command substitutions are expanded inside a here-doc.

### Suppress Expansion with Quoted Label

Quoting the label prevents all expansion -- everything is treated as literal text:

```bash
cat <<'EOF'
This is literal: ${userName}
This is also literal: $(date)
EOF
```

### Writing a File with a Here-Doc

```bash
cat > /tmp/config.txt <<EOF
# Generated on $(date)
serverName="${hostName}"
logLevel=2
EOF
```

### Indented Here-Docs with `<<-`

`<<-` strips leading **tabs** (not spaces) from the body and the closing label, so the here-doc can be indented inside a function or loop:

```bash
function write_config() {
	cat > /tmp/config.txt <<-EOF
		# Generated on $(date)
		serverName="${hostName}"
		logLevel=2
	EOF
}
```

> **Note:** This only strips tabs. If your editor converts tabs to spaces, `<<-` won't work.

> **Copy-paste warning:** The code block above requires real tab characters. If you copy it from a rendered web page (like GitHub), your browser may convert tabs to spaces, silently breaking the heredoc. Type the tabs yourself or verify with `cat -A` (tabs show as `^I`).

---

## Here-Strings

A here-string feeds a single string to a command's stdin. Shorter than a here-doc when you only have one line:

```bash
grep "error" <<< "${logContents}"
```

Variables are expanded. Equivalent to `echo "${logContents}" | grep "error"` but avoids creating a pipe and forking an extra process.
