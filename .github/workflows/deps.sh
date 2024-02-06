#!/bin/bash
set -eo pipefail
echo "Begin - ${0##*/}"

function ee {
    echo "$ $*"
    eval "$@"
}

# apt
ee apt-get update -qq
ee apt-get install -yqq \
    bats \
    curl \
    git \
    make \
    python3-bashate \
    shellcheck
# bpkg
ee curl -fsSL 'https://raw.githubusercontent.com/bpkg/bpkg/master/setup.sh' -o ~/Downloads/bpkg-setup.sh
ee chmod +x ~/Downloads/bpkg-setup.sh
ee ~/Downloads/bpkg-setup.sh

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
ee bashate --version
ee shellcheck --version

echo "Done. - ${0##*/}"
