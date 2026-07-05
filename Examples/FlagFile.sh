#!/bin/zsh --no-rcs
# shellcheck shell=bash
#set -x

# FlagFile.sh by: Trevor Sysock
# 2026-07-04
# v.0.0

# The purpose of this script is to demonstrate how to write a plist "flag" file
# If you only ever want a script running one time, you can write a flag file to 
# ensure that subsequent runs exit early

# You can also use this for orchestration, if another script determines this needs to
# run again, then have it delete the flag file

#####################
#   Configuration   #
#####################
flagFilePath="/Users/Shared/.FlagFileExample.plist"

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
pBuddy="/usr/libexec/PlistBuddy"


#################
#   Functions   #
#################
function check_flag_file(){
    if [[ -e "$flagFilePath" ]]; then
        echo "No action needed, exiting"
        exit 0
    else
        echo "Script needs to run."
    fi
}

function write_flag_file(){
    "$pBuddy" -c "Add RunTime date $(date)" "$flagFilePath" > /dev/null 2>&1 
}

##########################
#   Script Starts Here   #
##########################

check_flag_file

echo "I am a script. I am doing things here"

write_flag_file