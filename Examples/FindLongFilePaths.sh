#!/bin/zsh --no-rcs
# shellcheck shell=bash
#set -x

# FindLongFilePaths.sh by: Trevor Sysock
# 2026-07-04
# v.0.0

#####################
#   Configuration   #
#####################
searchDir="/Users/Shared"
pathMax=200

####################################
# DO NOT EDIT BELOW FOR NORMAL USE #
####################################
# Syntax:
#   Variables and arrays are "camel case": $thisIsAVariable
#   Functions are "snake case": this_is_a_function
#   Functions are declared with the declaration of "function this_is_a_function(){}"

#################
#   Variables   #
#################

fileList=()

#################
#   Functions   #
#################


##########################
#   Script Starts Here   #
##########################


while IFS=  read -r -d $'\0'; do
    #$REPLY is our relative file path, this is part of the `read` command
    currentFile="${REPLY}"
    if [[ "${#currentFile}" -gt "${pathMax}" ]]; then
        fileList+=("$currentFile")
    fi
done < <(find "$searchDir" -print0 2>/dev/null)

for i in "${fileList[@]}"; do
    echo "I am a very long file: $i"
done
