#!/bin/bash
set -eo pipefail
echo "Begin - ${0##*/}"

function ee {
    echo "$ $*"
    eval "$@"
}

# apt
ee sudo apt-get update -qq
ee sudo apt-get install -yqq \
    bats \
    curl \
    git \
    make \
    python3-bashate \
    shellcheck
# bpkg
ee curl -fsSL 'https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh' -o bpkg-setup.sh
ee chmod +x bpkg-setup.sh
ee sudo ./bpkg-setup.sh

# versions
source /etc/os-release
echo "$NAME $VERSION"
ee uname -r
ee bash --version
ee bats --version
ee bpkg --version
ee curl --version
ee git --version
ee make --version
ee shellcheck --version

echo "Done. - ${0##*/}"
