#!/usr/bin/env bats

export BASE_CASE='echo "test"'

@test 'test environment > GNU grep is installed' {
    grep --version | grep 'GNU' >/dev/null
}

@test 'ee.sh > exists' {
    [[ -f 'ee.sh' ]] && true || false
}

@test 'ee.sh > is executable' {
    [[ -x 'ee.sh' ]] && true || false
}

@test 'ee.sh > shell prompt > exists' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -P '[$#]' >/dev/null
}

@test 'ee.sh > shell prompt > has no prefix' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -P '^[$#]' >/dev/null
}

@test 'ee.sh > shell prompt > is followed by exactly one space' {
    TEST_STDOUT="$(./ee.sh)"
    echo "$TEST_STDOUT" | grep -P '[$#]+ $' >/dev/null
}

@test 'ee.sh > shell prompt > is on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | head -n 1 | grep -P '[$#]' >/dev/null
}

@test 'ee.sh > shell prompt > is one character' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -P '^[^$#]*[$#][^$#]*$' >/dev/null
}

@test 'ee.sh > shell prompt > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP '[$#]+' | wc -l)"
    [[ "$COUNT" == '1' ]] && true || false
}

@test 'ee.sh > shell prompt > uses dollar sign' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -P '^[^$#]*[$]+[^$#]*$' >/dev/null
}
