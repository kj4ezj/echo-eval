#!/bin/bash
function ee {
    echo "$ $*"
    eval "$@"
}

# enable this script to be sourced or invoked directly, following bpkg instructions
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    export -f ee
else
    ee "${@}"
    exit "$?"
fi

# https://github.com/kj4ezj/ee
# Copyright © 2022 Zach Butler
