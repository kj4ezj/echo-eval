#!/bin/bash
set -eo pipefail
echo "Begin - ${0##*/}"

function ee {
    echo "$ $*"
    eval "$@"
}

ee shellcheck -x -f gcc ee.sh ee.test.bats
ee bashate -i E006 ee.sh
ee bashate -i E006,E040 ee.test.bats

echo "Done. - ${0##*/}"
