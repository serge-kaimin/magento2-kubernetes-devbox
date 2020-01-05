#!/bin/bash
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
# Universal Bash parameter parsing
# Parse equal sign separated params into named local variables
# Standalone named parameter value will equal its param name (--force creates variable $force=="force")
# Parses multi-valued named params into an array (--path=path1 --path=path2 creates ${path[*]} array)
# Puts un-named params as-is into ${ARGV[*]} array
# Additionally puts all named params as-is into ${ARGN[*]} array
# Additionally puts all standalone "option" params as-is into ${ARGO[*]} array
# @author Oleksii Chekulaiev
# Prefix added by 
# @author Sergey Kaimin
# @version v1.5.0 (Dec-31-2019)
# @TODO: Remove: $Arg_parser_prefix Add parsing argument: -pRfx=Devbox_
# @TODO: add Devbox_arg_v for variables
# @TODO: -OPT 1 put Devbox_arg_OPT="1"
# TODO sort args to pass it in right orded to sub-programs
parse_params ()
{
    local existing_named
    # shellcheck disable=SC2034
    #local ARGV=() # un-named params
    # shellcheck disable=SC2034
    #local ARGN=() # named params
    # shellcheck disable=SC2034
    #local ARGO=() # options (--params)
    #TODO refactoring required to not use external variable Arg_parser_prefix
    # shellcheck disable=SC2154
    Prefix=$Arg_parser_prefix
    echo "${Prefix}ARGV=(); ${Prefix}ARGN=(); ${Prefix}ARGO=();"
    while [[ "$1" != "" ]]; do
        # Escape asterisk to prevent bash asterisk expansion, and quotes to prevent string breakage
        _escaped=${1/\*/\'\"*\"\'}
        _escaped=${_escaped//\'/\\\'}
        _escaped=${_escaped//\"/\\\"}
        # If equals delimited named parameter
        nonspace="[^[:space:]]"
        if [[ "$1" =~ ^${nonspace}${nonspace}*=..* ]]; then
            # Add to named parameters array
            echo "${Prefix}ARGN+=('$_escaped');"
            # key is part before first =
            local _key
            _key=$(echo "$1" | cut -d = -f 1)
            # Just add as non-named when key is empty or contains space
            if [[ "$_key" == "" || "$_key" =~ " " ]]; then
                echo "${Prefix}ARGV+=('$_escaped');"
                shift
                continue
            fi
            # val is everything after key and = (protect from param==value error)
            local _val="${1/$_key=}"
            # remove dashes from key name
            _key=${_key//\-}
            # skip when key is empty
            # search for existing parameter name
            if (echo "${Prefix}$existing_named" | grep "\b$_key\b" >/dev/null); then
                # if name already exists then it's a multi-value named parameter
                # re-declare it as an array if needed
                if ! (declare -p _key 2> /dev/null | grep -q 'declare \-a'); then
                    echo "${Prefix}'_arg_'$_key=(\"\$$_key\");"
                fi
                # append new value
                echo "${Prefix}_arg_$_key+=('$_val');"
            else
                # single-value named parameter
                echo "${Prefix}_arg_$_key='$_val';"
                existing_named=" $_key"
            fi
        # If standalone named parameter
        elif [[ "$1" =~ ^\-${nonspace}+ ]]; then
            # remove dashes
            local _key=${1//\-}
            # Just add as non-named when key is empty or contains space
            if [[ "$_key" == "" || "$_key" =~ " " ]]; then
                echo "${Prefix}ARGV+=('$_escaped');"
                shift
                continue
            fi
            # Add to options array
            echo "${Prefix}ARGO+=('$_escaped');"
            echo "${Prefix}$_key=\"$_key\";"
        # non-named parameter
        else
            # Escape asterisk to prevent bash asterisk expansion
            _escaped=${1/\*/\'\"*\"\'}
            echo "${Prefix}ARGV+=('$_escaped');"
        fi
        shift
    done
}

#--------------------------- DEMO OF THE USAGE -------------------------------

#show_use ()
#{
#    eval $(parse_params "$@")
#    # --
#    echo "${ARGV[0]}" # print first unnamed param
#    echo "${ARGV[1]}" # print second unnamed param
#    echo "${ARGN[0]}" # print first named param
#    echo "${ARG0[0]}" # print first option param (--force)
#    echo "$anyparam"  # print --anyparam value
#    echo "$k"         # print k=5 value
#    echo "${multivalue[0]}" # print first value of multi-value
#    echo "${multivalue[1]}" # print second value of multi-value
#    [[ "$force" == "force" ]] && echo "\$force is set so let the force be with you"
#}