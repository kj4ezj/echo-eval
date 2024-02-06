#!/usr/bin/env bats

# smoke tests
@test 'smoke test > dc is installed' {
    dc --version >/dev/null
}

@test 'smoke test > GNU grep is installed' {
    grep --version | grep 'GNU' >/dev/null
}

# generic tests
@test 'ee.sh > exists' {
    [[ -f 'ee.sh' ]]
}

@test 'ee.sh > is executable' {
    [[ -x 'ee.sh' ]]
}

@test 'ee.sh > returns EXIT_SUCCESS by default' {
    ./ee.sh >/dev/null
}

# shellcheck disable=SC2016
@test 'ee.sh > runs the given command, performing evaluation internally' {
    TEST_STDOUT="$(./ee.sh 'echo "${BASH_SOURCE[0]}"' || :)"
    echo "$TEST_STDOUT" | grep './ee.sh' >/dev/null
}

##### BASE CASE #####
export BASE_CASE="dc -e '1 2 + p'"
export BASE_CASE_CMD='dc'
export BASE_CASE_ARG1='-e'
export BASE_CASE_ARG2="'1 2 + p'"
export BASE_CASE_RESULT='3'

# base case > command
@test 'ee.sh > base case > command > is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep "$BASE_CASE_CMD" >/dev/null
}

@test 'ee.sh > base case > command > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP "$BASE_CASE_CMD" | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > base case > command > is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep "$BASE_CASE_CMD" >/dev/null
}

@test 'ee.sh > base case > command > is right after shell prompt' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -P "[\$#]+[ \t]+$BASE_CASE_CMD" >/dev/null
}

@test 'ee.sh > base case > command > is with arguments' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep "$BASE_CASE" >/dev/null
}

# base case > parameters
@test 'ee.sh > base case > parameters > arg1 is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > base case > parameters > arg1 is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP -- "$BASE_CASE_ARG1" | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > base case > parameters > arg1 is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep -- "$BASE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > base case > parameters > arg1 is right after command' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_CMD $BASE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > base case > parameters > arg2 is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_ARG2" >/dev/null
}

@test 'ee.sh > base case > parameters > arg2 is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep -- "$BASE_CASE_ARG2" >/dev/null
}

@test 'ee.sh > base case > parameters > arg2 is right after arg1' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -- "$BASE_CASE_ARG1 $BASE_CASE_ARG2" >/dev/null
}

# base case > result
@test 'ee.sh > base case > result > does not write to STDERR' {
    ./ee.sh "$BASE_CASE" >/dev/null 2>test.out || :
    TEST_STDERR="$(cat test.out)"
    rm test.out
    [[ "$(printf "$TEST_STDERR" | wc -c)" == '0' ]]
}

@test 'ee.sh > base case > result > is printed' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep "$BASE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > base case > result > is printed alone on line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -P "^$BASE_CASE_RESULT\$" >/dev/null
}

@test 'ee.sh > base case > result > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP "$BASE_CASE_RESULT" | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > base case > result > is printed on last line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | tail -n 1 | grep "$BASE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > base case > result > is printed on second line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | head -n 2 | tail -n 1 | grep "$BASE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > base case > result > returns EXIT_SUCCESS' {
    ./ee.sh "$BASE_CASE" >/dev/null
}

# base case > shell prompt
@test 'ee.sh > base case > shell prompt > exists' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -P '[$#]' >/dev/null
}

@test 'ee.sh > base case > shell prompt > has no prefix' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -P '^[$#]' >/dev/null
}

@test 'ee.sh > base case > shell prompt > is followed by exactly one space' {
    TEST_STDOUT="$(./ee.sh || :)"
    echo "$TEST_STDOUT" | grep -P '[$#]+ $' >/dev/null
}

@test 'ee.sh > base case > shell prompt > is on first line' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep -P '[$#]' >/dev/null
}

@test 'ee.sh > base case > shell prompt > is one character' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -P '^[^$#]*[$#][^$#]*$' >/dev/null
}

@test 'ee.sh > base case > shell prompt > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP '[$#]+' | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > base case > shell prompt > uses dollar sign' {
    TEST_STDOUT="$(./ee.sh "$BASE_CASE" || :)"
    echo "$TEST_STDOUT" | grep -P '^[^$#]*[$]+[^$#]*$' >/dev/null
}

##### FAILURE CASE #####
export FAILURE_CASE='grep pattern imaginary.txt'
export FAILURE_CASE_CMD='grep'
export FAILURE_CASE_ARG1='pattern'
export FAILURE_CASE_ARG2='imaginary.txt'
export FAILURE_CASE_RESULT='grep: imaginary.txt: No such file or directory'
export FAILURE_CASE_EXIT_STATUS='2'

# failure case > command
@test 'ee.sh > failure case > command > is printed' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep "$FAILURE_CASE_CMD" >/dev/null
}

@test 'ee.sh > failure case > command > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP "$FAILURE_CASE_CMD" | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > failure case > command > is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep "$FAILURE_CASE_CMD" >/dev/null
}

@test 'ee.sh > failure case > command > is right after shell prompt' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -P "[\$#]+[ \t]+$FAILURE_CASE_CMD" >/dev/null
}

@test 'ee.sh > failure case > command > is with arguments' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep "$FAILURE_CASE" >/dev/null
}

# failure case > parameters
@test 'ee.sh > failure case > parameters > arg1 is printed' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -- "$FAILURE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > failure case > parameters > arg1 is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP -- "$FAILURE_CASE_ARG1" | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > failure case > parameters > arg1 is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep -- "$FAILURE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > failure case > parameters > arg1 is right after command' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -- "$FAILURE_CASE_CMD $FAILURE_CASE_ARG1" >/dev/null
}

@test 'ee.sh > failure case > parameters > arg2 is printed' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -- "$FAILURE_CASE_ARG2" >/dev/null
}

@test 'ee.sh > failure case > parameters > arg2 is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP -- "$FAILURE_CASE_ARG2" | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > failure case > parameters > arg2 is printed on first line' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep -- "$FAILURE_CASE_ARG2" >/dev/null
}

@test 'ee.sh > failure case > parameters > arg2 is right after arg1' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -- "$FAILURE_CASE_ARG1 $FAILURE_CASE_ARG2" >/dev/null
}

# failure case > result
@test 'ee.sh > failure case > result > is printed' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>&1 || :)"
    echo "$TEST_STDOUT" | grep "$FAILURE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > failure case > result > is printed alone on line' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>&1 || :)"
    echo "$TEST_STDOUT" | grep -P "^$FAILURE_CASE_RESULT\$" >/dev/null
}

@test 'ee.sh > failure case > result > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>&1 || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP "$FAILURE_CASE_RESULT" | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > failure case > result > is printed on last line' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>&1 || :)"
    echo "$TEST_STDOUT" | tail -n 1 | grep "$FAILURE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > failure case > result > is printed on second line' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>&1 || :)"
    echo "$TEST_STDOUT" | head -n 2 | tail -n 1 | grep "$FAILURE_CASE_RESULT" >/dev/null
}

@test 'ee.sh > failure case > result > returns EXIT_FAILURE' {
    ./ee.sh "$FAILURE_CASE" >/dev/null 2>&1 && false || true
}

@test 'ee.sh > failure case > result > returns exit status from command' {
    ./ee.sh "$FAILURE_CASE" >/dev/null 2>&1 && false || [[ "$?" == 2 ]]
}

# failure case > shell prompt
@test 'ee.sh > failure case > shell prompt > exists' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -P '[$#]' >/dev/null
}

@test 'ee.sh > failure case > shell prompt > has no prefix' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -P '^[$#]' >/dev/null
}

@test 'ee.sh > failure case > shell prompt > is followed by exactly one space' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -P '[$#]+ [^ \t]' >/dev/null
}

@test 'ee.sh > failure case > shell prompt > is on first line' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | head -n 1 | grep -P '[$#]' >/dev/null
}

@test 'ee.sh > failure case > shell prompt > is one character' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -P '^[^$#]*[$#][^$#]*$' >/dev/null
}

@test 'ee.sh > failure case > shell prompt > is printed exactly once' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    COUNT="$(echo "$TEST_STDOUT" | grep -oP '[$#]+' | wc -l)"
    [[ "$COUNT" == '1' ]]
}

@test 'ee.sh > failure case > shell prompt > uses dollar sign' {
    TEST_STDOUT="$(./ee.sh "$FAILURE_CASE" 2>/dev/null || :)"
    echo "$TEST_STDOUT" | grep -P '^[^$#]*[$]+[^$#]*$' >/dev/null
}
