#!/bin/sh
# Builds the program, or runs its tests: ./build.sh, ./build.sh test.
# ARCHE_HOME is the arche-lang checkout, with its compiler built.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
arche_home=${ARCHE_HOME:-$HOME/Desktop/arche/arche-lang}
cd "$here"
case ${1:-build} in
build)
    mkdir -p build
    "$arche_home/compiler/arche-build" main.arche build/vazifa
    echo "build/vazifa"
    ;;
test)
    # arche-test runs the test blocks of the file it is given.
    for module in date board cli store report; do
        echo "== $module"
        "$arche_home/compiler/arche-test" "$module.arche"
    done
    ;;
*)
    echo "usage: build.sh [build | test]" >&2
    exit 2
    ;;
esac
