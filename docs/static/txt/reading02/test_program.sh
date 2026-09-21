#!/bin/bash

WORKSPACE=/tmp/reading02.$(id -u)
FAILURES=0
SHASUM=sha1sum

error() {
    echo "$@"
    echo
    case "$@" in
    *Output*)
	printf "%-60s%-60s\n" "PROGRAM OUTPUT" "EXPECTED OUTPUT"
	cat $WORKSPACE/test.diff
	echo
	;;
    *Valgrind*)
    	cat $WORKSPACE/test.stderr
    	echo
	;;
    *)
    	[ -r $WORKSPACE/text ] && cat $WORKSPACE/test
    	echo
	;;
    esac
    FAILURES=$((FAILURES + 1))
}

cleanup() {
    STATUS=${1:-$FAILURES}
    rm -fr $WORKSPACE

    if [ "$STATUS" -eq 0 ]; then
	echo "  Status Success"
    else
	echo "  Status Failure"
    fi

    echo
    exit $STATUS
}

grep_all() {
    for pattern in $1; do
	if ! grep -q -E "$pattern" $2; then
	    echo "FAILURE: Missing '$pattern' in '$2'" > $WORKSPACE/test
	    return 1;
	fi
    done
    return 0;
}

grep_any() {
    for pattern in $1; do
	if grep -q -E "$pattern" $2; then
	    echo "FAILURE: Contains '$pattern' in '$2'" > $WORKSPACE/test
	    return 1;
	fi
    done
    return 0;
}

count_valgrind_errors() {
    python3 <<EOF
import sys
print(sum(int(line.split()[3]) for line in sys.stdin if 'ERROR SUMMARY' in line))
EOF
}

test_program() {
    ARGUMENTS="$1"
    EXITCODE=$2
    NODIFF=$3

    printf " %-60s ... " "program $ARGUMENTS"
    valgrind --leak-check=full --trace-children=yes ./program $ARGUMENTS > $WORKSPACE/test.stdout 2> $WORKSPACE/test.stderr
    if [ $? -ne $EXITCODE ]; then
	error "Failure (Exit Code)"
    elif [ "$NODIFF" = "" ] && ! diff -W 120 -y <(sort $WORKSPACE/test.stdout) <($SHASUM $ARGUMENTS 2> /dev/null | sort) &> $WORKSPACE/test.diff; then
	error "Failure (Output)"
    elif [ $(count_valgrind_errors < $WORKSPACE/test.stderr) -ne 0 ]; then
	error "Failure (Valgrind)"
    else
	echo "Success"
    fi
}


mkdir $WORKSPACE

trap "cleanup" EXIT
trap "cleanup 1" INT TERM

echo "Testing reading02 program ... "


printf " %-60s ... " "I/O System Calls"
if ! grep_all "open read close" program.c; then
    error "Failure"
else
    echo "Success"
fi


printf " %-60s ... " "I/O Functions"
if ! grep_any "fopen fread fclose popen" program.c; then
    error "Failure"
else
    echo "Success"
fi


printf " %-60s ... " "Memory Functions"
if ! grep_any "malloc calloc" program.c; then
    error "Failure"
else
    echo "Success"
fi


printf " %-60s ... " "Crypto Functions"
if ! grep_all "SHA_DIGEST_LENGTH EVP_DigestInit_ex EVP_DigestUpdate EVP_DigestFinal_ex" program.c; then
    error "Failure"
else
    echo "Success"
fi


test_program "" 0 nodiff
test_program "Makefile" 0
test_program "Makefile README.md" 0
test_program "Makefile README.md program.c" 0
test_program "Makefile README.md program.c asdf" 1
test_program "Makefile asdf README.md program.c fsda" 2
test_program "Makefile README.md /bin/ls /bin/bash" 0


TESTS=$(($(grep -c Success $0) + $(grep -c test_program $0) - 5))
SCORE=$(python3 <<EOF
print("{:5.2f} / $TESTS.00".format(($TESTS - $FAILURES)))
EOF
)
GRADE=$(python3 <<EOF
print("{:5.2f} /  1.00".format(($TESTS - $FAILURES) / $TESTS.0))
EOF
)
echo "   Score $SCORE"
echo "   Grade $GRADE"
