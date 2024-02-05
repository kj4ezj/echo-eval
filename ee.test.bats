#!/usr/bin/env bats

@test 'ee.sh > exists' {
    [[ -f 'ee.sh' ]] && true || false
}

@test 'ee.sh > is executable' {
    [[ -x 'ee.sh' ]] && true || false
}

@test 'ee.sh > output > begins with shell prompt' {
    TEST_STDOUT="$(./ee.sh 'echo test')"
    echo "$TEST_STDOUT" | tr -d '\r\n' | grep -P '^[$#]' >/dev/null
}

@test 'ee.sh > output > shell prompt is a dollar sign' {
    TEST_STDOUT="$(./ee.sh 'echo test')"
    echo "$TEST_STDOUT" | tr -d '\r\n' | grep -P '^[$]' >/dev/null
}

@test 'ee.sh > output > shell prompt is followed by exactly one space' {
    TEST_STDOUT="$(./ee.sh 'echo test')"
    echo "$TEST_STDOUT" | tr -d '\r\n' | grep -P '^. [^ ]' >/dev/null
}

@test 'ee.sh > output > shell prompt is on first line' {
    TEST_STDOUT="$(./ee.sh 'echo test')"
    echo "$TEST_STDOUT" | head -n 1 | grep -P '^[$#]' >/dev/null
}
