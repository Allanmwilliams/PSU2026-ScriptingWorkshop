#!/bin/zsh --no-rcs
# shellcheck shell=bash
#set -x

# DockSetup.sh by: Trevor Sysock
# 2026-07-04
# v.0.0

#####################
#   Configuration   #
#####################
# Add a list of apps to the dock
## Our app list
appsToAdd=(
    "/System/Cryptexes/App/System/Applications/Safari.app"
    "/Applications/OBS.app"
)

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
currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ { print $3 }' )
uid=$(id -u "$currentUser" 2> /dev/null)
userHomeFolder=$(dscl . -read /users/${currentUser} NFSHomeDirectory | cut -d " " -f 2)

dockutilPath="/usr/local/bin/dockutil"
dockPlist="${userHomeFolder}/Library/Preferences/com.apple.dock.plist"

#################
#   Functions   #
#################
function dock_add_if_exists(){
    #Usage: dock_add_if_exists /path/to/dock/item.app [options]
    if [ -e "${1}" ]; then
        sleep .5
        echo "Adding to dock: ${1}"
        "$dockutilPath" --add "${@}" --no-restart "${dockPlist}" > /dev/null 2>&1
    fi
}

##########################
#   Script Starts Here   #
##########################

## Our for loop
for item in "${appsToAdd[@]}"; do
    dock_add_if_exists "${item}"
done

# Kill the dock process (updates pending changes if using --no-restart)
killall Dock
