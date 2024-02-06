#!/usr/bin/env bats

export BASE_CASE="dc -e '1 2 + p'"
export BASE_CASE_CMD='dc'
export BASE_CASE_ARG1='-e'
export BASE_CASE_ARG2="'1 2 + p'"
export BASE_CASE_RESULT='3'

# smoke tests
@test 'smoke test > dc is installed' {
    dc --version >/dev/null
}

@test 'smoke test > GNU grep is installed' {
    grep --version | grep 'GNU' >/dev/null
}

# generic tests
@test 'ee.sh > exists' {
    [[ -f 'ee.sh' ]] && true || false
}

@test 'ee.sh > is executable' {
    [[ -x 'ee.sh' ]] && true || false
}

@test 'ee.sh > returns EXIT_SUCCESS by default' {
    ./ee.sh >/dev/null
}

@test 'ee.sh > runs the given command, performing evaluation internally' {
    TEST_STDOUT="$(./ee.sh 'echo "${BASH_SOURCE[0]}"')"
    echo "$TEST_STDOUT" | grep './ee.sh' >/dev/null
}

# base case > command
@test 'ee.sh > base case > command > is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep "$BASE_CASE_CMD" >/dev/null
}

@test 'ee.sh > base case > command > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP "$BASE_CASE_CMD" | wc -l)"
    [[ "$COUNT" == '1' ]] && true || false
}

@test 'ee.sh > base case > command > is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | head -n 1 | grep "$BASE_CASE_CMD" >/dev/null
}

@test 'ee.sh > base case > command > is right after shell prompt' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -P "[\$#]+[ \t]+$BASE_CASE_CMD" >/dev/null
}

@test 'ee.sh > base case > command > is with arguments' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep "$BASE_CASE" >/dev/null
}

# base case > parameters
@test 'ee.sh > base case > parameters > arg1 is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > base case > parameters > arg1 is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP -- "$BASE_CASE_ARG1" | wc -l)"
    [[ "$COUNT" == '1' ]] && true || false
}

@test 'ee.sh > base case > parameters > arg1 is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | head -n 1 | grep -- "$BASE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > base case > parameters > arg1 is right after command' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_CMD $BASE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > base case > parameters > arg2 is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_ARG2" >/dev/null
}

@test 'ee.sh > base case > parameters > arg2 is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | head -n 1 | grep -- "$BASE_CASE_ARG2" >/dev/null
}

@test 'ee.sh > base case > parameters > arg2 is right after arg1' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_ARG1 $BASE_CASE_ARG2" >/dev/null
}

# base case > result
@test 'ee.sh > base case > result > is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep "$BASE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > base case > result > is printed alone on line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | grep -P "^$BASE_CASE_RESULT\$" >/dev/null
}

@test 'ee.sh > base case > result > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP "$BASE_CASE_RESULT" | wc -l)"
    [[ "$COUNT" == '1' ]] && true || false
}

@test 'ee.sh > base case > result > is printed on last line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | tail -n 1 | grep "$BASE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > base case > result > is printed on second line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE")"
    echo "$TEST_STDOUT" | head -n 2 | tail -n 1 | grep "$BASE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > base case > result > returns EXIT_SUCCESS' {
    ./ee.sh "$BASE_CASE" >/dev/null
}

# shell prompt test cases
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
