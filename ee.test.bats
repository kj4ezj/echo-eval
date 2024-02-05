#!/usr/bin/env bats

@test 'ee.sh > exists' {
    [[ -f 'ee.sh' ]] && true || false
}

@test 'ee.sh > is executable' {
    [[ -x 'ee.sh' ]] && true || false
}
