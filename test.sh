#!/bin/bash
set -eo pipefail
echo "Begin - ${0##*/}"

function ff {  # use a different name than ee to remove ambiguity about what is under test
    echo "$ $*"
    eval "$@"
}

printf '\e[1;32m##### SMALL TESTS #####\e[0m\n'
ff ./ee.test.bats
if [[ "$CI" == 'true' && "$ACT" != 'true' ]]; then
    printf '\e[1;32m##### LARGE TESTS #####\e[0m\n'
    ff ./large-test.bats
else
    printf '\e[1;96mNOTICE: Skipping large tests because this is not a cloud CI environment.\e[0m\n'
fi

echo "Done. - ${0##*/}"
