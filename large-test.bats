#!/usr/bin/env bats

# smoke tests
@test 'smoke test > is running in CI' {
    [[ "$CI" == 'true' ]]
}

@test 'smoke test > is not running locally in act' {
    [[ "$ACT" != 'true' ]]
}

# shellcheck disable=SC2016,SC1091
@test 'ee.sh > bpkg > dependency installation' {
    unset ee
    bpkg install "kj4ezj/bpkg:$GITHUB_SHA"
    source 'deps/bin/ee'
    TEST_STDOUT="$(ee 'echo "${BASH_SOURCE[0]}"' || :)"
    echo "$TEST_STDOUT" | tail -1 | grep -P "^([.]/)?deps/bin/ee([.]sh)?\$"
}

# shellcheck disable=SC2016
@test 'ee.sh > bpkg > global installation' {
    unset ee
    sudo bpkg install -g "kj4ezj/bpkg:$GITHUB_SHA"
    TEST_STDOUT="$(ee 'echo "${BASH_SOURCE[0]}"' || :)"
    echo "$TEST_STDOUT" | tail -1 | grep -P "^/usr/local/bin/ee([.]sh)?\$"
}
