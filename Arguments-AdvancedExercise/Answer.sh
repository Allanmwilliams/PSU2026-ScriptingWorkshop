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

# Answer Key: #<--

# NOTE on argument parsing:
# We could go much deeper "sanity checking" the user's input here. For example, even in this completed script we don't protect against
#   a user mistakenly entering './Script.sh -s -v' while parsing arguments. Thats still going to fail later on.
#
# We have to choose where we draw the line at "good enough"

# Functions
function print_usage_and_exit(){
    # $1 is our exit code (optional, defaults 0)
    # $2 is our exit message (optional)

    # Print usage instructions
    echo "Usage: ./Script.sh [ -s | --source ] sourcedirectory [ -d | --destination ] destinationdirectory" #<--

    # Check if argument 2 was given, if so print to standard out
    if [ -n "$2" ]; then #<--
        echo "$2" #<--
    fi #<--

    # Exit with the given exit code. 
    #If no arguments were passed, then $1 expands empty and exit defaults to 0 (success)
    exit "$1"  #<--
}

# While we have arguments to parse
while [[ "$#" -gt 0 ]]; do
    # In case this argument matches
    case "$1" in
        -s|--source)
            # If the user didn't give another argument to go with `-s | --source` then we have to exit with an error
            if [ -z "$2" ]; then
                print_usage_and_exit 1 "ERROR: -s | --source requires an argument"
            fi
            # Set the source directory var and shift twice
            sourceDir="$2"
            shift 2
            ;;
        -d|--destination)
            # If the user didn't give another argument to go with `-s | --source` then we have to exit with an error
            if [ -z "$2" ]; then
                print_usage_and_exit 1 "ERROR: -d | --destination requires an argument"
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
        -h|--help) 
            # Print help text and exit #<--
            print_usage_and_exit 0 #<--
            ;; #<--
        *)
            # Some unknown option was given. Exit with an error.
            print_usage_and_exit 1 "Unknown option: $1" #<--
            ;;
    esac
done

# If verbose was set to true, then enable set -x
if [[ "$verbose" == true ]]; then #<--
    set -x #<--
fi #<--

# If either of our required variables weren't set, exit with an error.
if [ -z "$sourceDir" ] || [ -z "$destinationDir" ]; then
    print_usage_and_exit 2 "ERROR: Must provide both source and destination directories." #<--
fi

# If the source directory doesn't exist, print an error and exit
if ! [ -d "$sourceDir" ]; then  #<--
    print_usage_and_exit 3 "ERROR: Source directory does not exist: $sourceDir" #<--
# OR If the destination directory doesn't exist, print an error and exit
elif ! [ -d "$destinationDir" ]; then  #<--
    print_usage_and_exit 4 "ERROR: Destination directory does not exist: $destinationDir" #<--
# Else, everything looks good and we should continue
else #<--
    echo "Source directory confirmed: $sourceDir" #<--
    echo "Destination directory confirmed: $destinationDir" #<--
fi

exit 0 #<--
