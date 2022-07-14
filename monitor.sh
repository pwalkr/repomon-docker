#!/bin/bash

POLL_DELAY="${POLL_DELAY:-60}"
# 15 minutes from first seen change till commit
COMMIT_DELAY="${COMMIT_DELAY:-900}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-repomon sync}"

echo "Monitor starting"

upstream="$(git rev-parse --abbrev-ref "@{upstream}")"
while true; do
    sleep $POLL_DELAY

    if [ "$(git ls-files -mo)" ]; then
        echo "Local changes detected"
        sleep $COMMIT_DELAY
        git add .
        git commit -am "$COMMIT_MESSAGE"
        git push
    fi

    git fetch -p >/dev/null

    lrev="$(git rev-parse HEAD)"
    urev="$(git rev-parse "$upstream")"
    if [ "$lrev" != "$urev" ]; then
        if git rev-list HEAD | grep -q "$urev"; then
            echo "Retrying push"
            git push
        else
            echo "Remote changes detected"
            if git rev-list "$upstream" | grep -q "$lrev"; then
                git pull
            else
                if git rebase "$upstream"; then
                    git push
                else
                    echo "Failed to sync. Resetting to origin"
                    git rebase --abort
                    git clean -dfx
                    git reset --hard "$upstream"
                fi
            fi
        fi
    fi
done
