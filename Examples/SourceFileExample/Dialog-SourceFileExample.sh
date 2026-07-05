#!/bin/zsh --no-rcs
# shellcheck shell=bash
set -x

# DialogExample.sh by: Trevor Sysock
# 2026-07-04
# v.0.0

# This script is an example of how to source files
# It utilizes SwiftDialog, which is assumed to be installed

#####################
#   Configuration   #
#####################
# Art, Sales, or Accounting
department=Accounting

dialogOptions=(
    --icon "PSU2026.png"
    --ontop
    --moveable
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
dialogPath="/usr/local/bin/dialog"

#################
#   Functions   #
#################
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

##########################
#   Script Starts Here   #
##########################

# Source the file that contains our variables for this department
source_file "${department}.settings"

# Now that we have our variables, we can settup the message body of our dialog window
dialogMessage="Hello, and welcome to the $DEPT_NAME department.\n\n \
You will be reporting to:\
\n\n $SUPERVISOR\
\n\nBuilding $BUILDING\
\n\nFloor $FLOOR"

# Draw our dialog window
"$dialogPath" "${dialogOptions[@]}" \
    --message "${dialogMessage}" \
    --title "${COMPANY_NAME}" \
    --infobox "**Welcome to ${COMPANY_NAME}**"
