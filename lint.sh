#!/bin/bash
set -eo pipefail
echo "Begin - ${0##*/}"

function ee {
    echo "$ $*"
    eval "$@"
}

ee bashate -i E006 ee.sh
ee shellcheck -e SC2294 -x -f gcc ee.sh
ee bashate -i E006,E040 ee.test.bats
ee shellcheck -x -f gcc ee.test.bats

echo "Done. - ${0##*/}"
