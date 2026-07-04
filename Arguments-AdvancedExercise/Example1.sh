#!/bin/zsh --no-rcs
#set -x

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
