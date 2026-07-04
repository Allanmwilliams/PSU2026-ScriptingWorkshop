# Useful Mac Admin Code Snippets
## Author
Trevor Sysock aka @BigMacAcmin https://github.com/BigMacAdmin
> **Compatible with:** bash and zsh, unless noted otherwise.

# Local User Stuff
## Get info about the currently logged in user
```sh
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser" 2> /dev/null)
userHomeFolder=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)
```
## Run a command as the currently logged in user
```sh
# convenience function to run a command as the current user
# usage:
#   runAsUser command arguments...
function runAsUser() {  
  # shellcheck disable=SC2236
  if [ "$currentUser" != "loginwindow" ] && [ ! -z "$currentUser" ]; then
    launchctl asuser "$uid" sudo -u "$currentUser" "$@"
  else
    echo "No user logged in"
    exit 0
  fi
}
```
## Check if a user is an administrator (in the admin group)
```sh
dseditgroup -o checkmember -m "${username}" 'admin' &> /dev/null
```

## Check if a user has a secure token
```sh
sysadminctl -secureTokenStatus "${username}"
```

# While read Loops
## Loop over every user on the system and do something
### All users including service accounts
```sh
while read -r currentUser currentUID; do
# Read the command at the end of this while loop line by line (dscl . -list /Users UniqueID )
    #   Includes service accounts
    currentHomeFolder=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)
    echo "$currentUser has UID: $currentUID and home folder: $currentHomeFolder"
done < <(dscl . -list /Users UniqueID)
```
### Only real local users
```sh
# Read the command at the end of this while loop line by line (dscl . -list /Users UniqueID )
while read -r currentUser currentUID; do
    # If the UID value is under 501 or if the account starts with an underscore skip it
    if [[ "$currentUID" -lt 501 ]] || [[ "$currentUser" == _* ]]; then
      continue
    fi
    currentHomeFolder=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)
    echo "$currentUser has UID: $currentUID and home folder: $currentHomeFolder"
done < <(dscl . -list /Users UniqueID)
```

## Loop over all files from a `find` command
The `-d` option on `read` in combination with the `-print0` option on `find` allow us to process files that have linebreaks
```sh
searchDir="/Users/Shared"
fileList=()

while IFS=  read -r -d $'\0'; do
    #$REPLY is our relative file path, this is part of the `read` command
    currentFile="${REPLY}"
    fileList+=("$currentFile")
done < <(find "$searchDir" -print0)


for i in "${fileList[@]}"; do
    echo "I am a file: $i"
done
```

# Sourcing Helpers
## Safely source a file, checking readability and reporting success/failure
```sh
function source_file() {
    # $1 = The path to the file we want to source
    if ! [[ -r "${1}" ]]; then
        echo "ERROR: Sourced file is not readable: ${1}"
        return 1
    fi

    # shellcheck disable=SC1090
    if source "${1}"; then
        echo "Successfully sourced file: ${1}"
    else
        echo "ERROR: Failed to source file: ${1}"
        return 1
    fi
}
```

# PlistBuddy Toolset
This is a list of helper functions for working with plists using `/usr/libexec/PlistBuddy`

Run the `initialize_plist` function prior to any others in your script

```sh
# Configuration
targetPlist="/var/tmp/tracker.plist"

# Variables
pBuddy="/usr/libexec/PlistBuddy"

# Functions
function initialize_plist(){
    # If our tracker file doesn't exist or isn't valid xml, then we create a new file
    if [ ! -e "$targetPlist" ] || ! plutil -lint "$targetPlist"  > /dev/null 2>&1; then
        # Delete it if its corrupt
        rm -f "$targetPlist"  > /dev/null 2>&1
        # Create the tracker and initialize it with a start date
        write_value "CreationDate" "$(date)" "date"
    fi
}

function write_value(){
    # $1 is the key to write
    # $2 is the value of the key
    # $3 is the value type (Optional. Defaults to string if not provided)
    # Examples:
      ## Set a boolean
      # write_value BaselineCompleted true bool

      ## Set an integer
      # write_value SetupDuration 254 integer

      ## Set a date
      # write_value SophosRemovalDate "$(date)" date

      ## Set a string (no option 3)
      # write_value CoolestGuyInTheRoom "Brock"

      ## Delete a key/value pair
      # delete_value CoolestGuyInTheRoom

    local key="$1"
    local value="$2"
    local type="string"

    # Check if type option is provided
    if [ -n "$3" ]; then
        type="$3"
    fi

    # Delete the key if it already exists.
    "$pBuddy" -c "Delete $key" "$targetPlist"  > /dev/null 2>&1
    # Write the value
    if ! "$pBuddy" -c "Add $key $type $value" "$targetPlist" ; then
        echo "ERROR: Could not set key/type/value: $key $type $value"
        return 1
    fi
}

function delete_value(){
    # $1 is the key to delete
    local key="$1"
    # Delete the key if it already exists.
    "$pBuddy" -c "Delete $key" "$targetPlist"  > /dev/null 2>&1
}

# Script Starts Here

initialize_plist
```

# Check and Install Rosetta
`arch -x86_64 /usr/bin/true` is a command to force running `true` using the Intel x86 architecture

On an Intel device, this passes first try so the loop never begins.

On an Apple Silicon device with rosetta is installed this will succeed and the loop never begins.

Tries `$max` times waiting 10 seconds between attempts.
```sh
function install_rosetta(){
    count=0
    max=5
    while [[ $count -lt $max ]] && ! arch -x86_64 /usr/bin/true 2> /dev/null; do
        count=$(( count + 1 ))
        echo "Rosetta 2 not found. Installing now..."
        if softwareupdate --install-rosetta --agree-to-license; then
            echo "Rosetta 2 installed successfully"
        else
            echo "ERROR Installing Rosetta2 attempt: $count"
        fi
        sleep 10
    done

    if ! arch -x86_64 /usr/bin/true 2> /dev/null; then
        echo "FATAL ERROR: Rosetta2 could not be installed after $max attempts"
        return 1
    fi
}
```

## swiftDialog Fundamentals
This snippet sets up a lot of the fundamental pieces of a robust swiftDialog script
```sh
# Requires:
#   - scriptName=/somepath/script.sh

## Variables ##

scriptName=DialogShellFundamentals

dialogPath="/usr/local/bin/dialog"

dialogCommandFile="$(mktemp /var/tmp/${scriptName}.XXXXX)" ; chmod 644 "$dialogCommandFile"
dialogJson="$(mktemp /var/tmp/${scriptName}.XXXXX)" ; chmod 644 "$dialogJson"

## Functions ##

# execute a dialog command
function dialog_command(){
    /bin/echo "$@"  >> "$dialogCommandFile"
    #log_message "$@"
    sleep .1
}

dialogOptions=(
    --title "My Title"
    --message "My Message"
)

"$dialogPath" "${dialogOptions[@]}" --commandfile "$dialogCommandFile" &


# YOUR SCRIPT STUFF GOES HERE
sleep 4

## Cleanup ##
dialog_command "quit:"
rm -f "${dialogCommandFile}" > /dev/null 2>&1
rm -f "${dialogJson}" > /dev/null 2>&1
```
# Installing Packages
## Install a pkg That is Trusted
Valid signing identity required
```sh
installer -pkg "${1}" -target /
```
## Install a pkg Even If the Signing Identity is Untrusted or Expired
This is useful for deploying home grown packages, or packages which aren't signed but you've validated are safe
```sh
installer -allowUntrusted -pkg "${1}" -target /
```
# Dockutil Tools
These are snippets and tools to help create dockutil scripts
```sh
dockutilPath="/usr/local/bin/dockutil"

# Path to the user's dock plist. Required when running as root. 
# Assumes currentUser and userHomeFolder are already set
dockPlist="${userHomeFolder}/Library/Preferences/com.apple.dock.plist"

#Clear the dock
"$dockutilPath" --remove all --no-restart "${dockPlist}" > /dev/null 2>&1

#This looks at the app trying to be added to the dock, and only applies it if the item actually exists
function dock_add_if_exists(){
    #Usage: dock_add_if_exists /path/to/dock/item.app [options]
    if [ -e "${1}" ]; then
        sleep .5
        echo "Adding to dock: ${1}"
        "$dockutilPath" --add "${@}" --no-restart "${dockPlist}" > /dev/null 2>&1
    fi
}

# Add a list of apps to the dock
## Our app list
appsToAdd=(
    "/System/Cryptexes/App/System/Applications/Safari.app"
    "/Applications/zoom.us.app"
	"/Applications/Slack.app"
)
## Our for loop
for item in "${appsToAdd[@]}"; do
    dock_add_if_exists "${item}"
done

# Add a spacer
"$dockutilPath" --add '' --type spacer --section apps --no-restart "${dockPlist}"

# Add some user folders to the dock. Assume's currentUser and userHomeFolder are already set
dock_add_if_exists "${userHomeFolder}/Downloads" --view list
dock_add_if_exists "${userHomeFolder}/Documents" --view list

# Kill the dock process (updates pending changes if using --no-restart)
killall Dock
```