#!/usr/bin/env bash
set -e

CURRENT_DIR=$(pwd)
BASE_URL="https://www.python.org/ftp/python"
LOCAL_DIR="$HOME/.local"

# verify version provided is valid
# valid: 3 => 3.10.12
# valid: 3.8 => 3.8.17
# valid: 3.7.16 => 3.7.16
# invalid:

print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -l, --list      List available versions"
    echo "  -h, --help      Print this help message"
    echo ""
    echo "Examples:"
    echo "  $0 3.10.0 3.9.0 3.8.0 3.7.0"
    echo "  $0 3.10 3.9 3.8 3.7"
    echo "  $0 3.10.0 3.9.0 3.8.0 3.7.0 --list"
}

LIST_VERSIONS=false
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -l|--list)
            LIST_VERSIONS=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
		-*|--*)
            echo "Error: Unknown argument $1"
            exit 1
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

# restore positional parameters
set -- "${POSITIONAL[@]}"
unset POSITIONAL

ALL_VERSIONS="$(curl -skL "$BASE_URL" | \
    sed -n 's!.*href="\([0-9]\+\.[0-9]\+\.[0-9]\+\)/".*!\1!p' | \
    sort -V)"

if [[ $# -eq 0 ]]; then
    echo "Error: No version specified"
    exit 1
fi

SPECIFIED_VERSIONS=()
for version in "$@"; do
    if [[ "$version" =~ ^[0-9]+$ ]]; then
        SPECIFIED_VERSIONS+=("$(echo "$ALL_VERSIONS" | grep "^$version\." | tail -n1)")
    elif [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
        SPECIFIED_VERSIONS+=("$(echo "$ALL_VERSIONS" | grep "^$version\." | tail -n1)")
    elif [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        SPECIFIED_VERSIONS+=("$version")
    else
        echo "Error: Invalid version $version"
        exit 1
    fi
done

if $LIST_VERSIONS; then
    if [[ "${#SPECIFIED_VERSIONS[@]}" -eq 0 ]]; then
        echo "$ALL_VERSIONS"
    else
        # echo all closely matching to specified versions
        for version in "${SPECIFIED_VERSIONS[@]}"; do
            echo "$ALL_VERSIONS" | grep "^$version\."
        done
    fi
    exit 0
fi

# check if make is installed
if ! command -v make &> /dev/null; then
    echo "Error: make is not installed"
    exit 1
fi

# check if user has an acceptable c compiler
if ! command -v gcc &> /dev/null; then
    echo "Error: gcc is not installed"
    exit 1
fi

# create local dir if it doesn't exist
if [[ ! -d "$LOCAL_DIR" ]]; then
    mkdir -p "$LOCAL_DIR"
fi

echo "Installing Python versions: ${SPECIFIED_VERSIONS[*]}"

for version in "${SPECIFIED_VERSIONS[@]}"; do
    if [[ -d "$LOCAL_DIR/python-$version" ]]; then
        echo "Python $version already installed"
        continue
    fi

    echo "Installing Python $version"

    cd "$LOCAL_DIR"
    curl -skL "$BASE_URL/$version/Python-$version.tgz" | tar -xz
    cd "Python-$version"
    ./configure --prefix="$LOCAL_DIR/python-$version"
    make -j"$(nproc)"
    make install
done

echo ""
echo "Python versions installed to $LOCAL_DIR/python-<version>"

cd "$CURRENT_DIR"
exit 0
