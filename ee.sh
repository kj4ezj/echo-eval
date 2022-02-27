#!/bin/bash
function ee()
{
    printf "\e[2m$ $*\e[0m\n"
    eval "$@"
}
