#!/bin/zsh --no-rcs
#set -x

# Exercise Instructions:
# 1. Make a "print_usage_and_exit" function with positional arguments that use an exit code and print a message to standard output
# 2. Replace the repeated usage "echo" commands with our function
# 3. Create conditionals that check if our source and destination directories exist. 
#   - If either entry doesn't exist, print the usage with a descriptive error message and exit with an error
#   - If they both exist, print some confirmation text to standard out which includes the path names and exit with success
# 4. Create a named argument that prints our help text and exits
# 5. When -v | --verbose is used, enabled set -x, but only after all arguments are processed.

# Remember that there are many ways to approach this, and Answser.sh can be referenced to see one solution

# Functions
function print_usage_and_exit(){
    # $1 is our exit code (optional, defaults 0)
    # $2 is our exit message (optional)


}

# While we have arguments to parse
while [[ "$#" -gt 0 ]]; do
    # In case this argument matches
    case "$1" in
        -s|--source)
            # If the user didn't give another argument to go with `-s | --source` then we have to exit with an error
            if [ -z "$2" ]; then
                echo "ERROR: -s | --source requires an argument"
                exit 1
            fi
            # Set the source directory var and shift twice
            sourceDir="$2"
            shift 2
            ;;
        -d|--destination)
            # If the user didn't give another argument to go with `-s | --source` then we have to exit with an error
            if [ -z "$2" ]; then
                echo "ERROR: -d | --destination requires an argument"
                exit 1
            fi
            # Set the destination directory var and shift twice
            destinationDir="$2"
            shift 2
            ;;
        -v|--verbose)
            # Set the verbose flag to true, and shift
            verbose=true
            shift
            ;;
        *)
            # Some unknown option was given. Exit with an error.
            echo "Unknown option: $1"
            echo "Usage: ./Script.sh [ -s | --source ] sourcedirectory [ -d | --destination ] destinationdirectory"
            exit 1
            ;;
    esac
done

# If either of our required variables weren't set, exit with an error.
if [ -z "$sourceDir" ] || [ -z "$destinationDir" ]; then
    echo "ERROR: Must provide both source and destination directories."
    echo "Usage: ./Script.sh [ -s | --source ] sourcedirectory [ -d | --destination ] destinationdirectory"
    exit 1
fi
