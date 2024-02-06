#!/bin/bash
set -eo pipefail
echo "Begin - ${0##*/}"

function ee {
    echo "$ $*"
    eval "$@"
}

printf '\e[1;35m===== Lint ee.sh =====\e[0m\n'
ee bashate -i E006 ee.sh
ee shellcheck -e SC2294 -x -f gcc ee.sh
printf '\e[1;34m===== Lint Tests =====\e[0m\n'
ee bashate -i E006,E040 ee.test.bats
ee shellcheck -f gcc ee.test.bats
ee bashate -i E006,E040 large-test.bats
ee shellcheck -f gcc large-test.bats
printf '\e[37m===== Lint CI =====\e[0m\n'
ee bashate -i E006 .github/workflows/deps.sh
ee shellcheck -e SC2294 -x -f gcc .github/workflows/deps.sh
ee bashate -i E006 lint.sh
ee shellcheck -e SC2294 -x -f gcc lint.sh
ee bashate -i E006 test.sh
ee shellcheck -e SC2294 -x -f gcc test.sh

echo "Done. - ${0##*/}"
