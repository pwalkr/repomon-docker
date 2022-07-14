#!/bin/sh

REPOSITORY_ROOT="${REPOSITORY_ROOT:-/data}"

# If repository is not populated, clone
if [ -z "$(ls "$REPOSITORY_ROOT" 2>/dev/null)" ]; then
    if [ -z "$GIT_REPO" ]; then
        echo "Please set GIT_REPO to something we can clone"
        exit 1
    fi
    set -x
    git clone --recurse-submodules "$GIT_REPO" "$REPOSITORY_ROOT" || exit 1
    { set +x; } 2>/dev/null
fi

cd "$REPOSITORY_ROOT"

if [ "$GIT_NAME" ]; then
    export GIT_AUTHOR_NAME="$GIT_NAME"
    export GIT_COMMITTER_NAME="$GIT_NAME"
fi

if [ "$GIT_EMAIL" ]; then
    export GIT_AUTHOR_EMAIL="$GIT_EMAIL"
    export GIT_COMMITTER_EMAIL="$GIT_EMAIL"
fi

monitor.sh
