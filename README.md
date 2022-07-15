# Repomon Repository Monitoring Container

This image enables cloning and monitoring a git repository for small local services.
Originally developed to provide a backend for [beancount](https://beancount.github.io/docs/index.html) server [fava](https://beancount.github.io/fava/).

This is a poll-based monitor.
Periodically, the local repository is checked for changes, and the monitor will commit+push back to remote.
Upstream changes are handled as follows:
1. Pull if possible
2. Rebase if out of sync
3. Reset to origin if all else fails

## Build

    docker build -t local/repomon .

## Run

Minimal docker call to watch an existing repository

    docker run --rm -d \
        -v $PWD:/data \
        -e GIT_USER=you \
        -e GIT_PASSWORD=$TOKEN \
        local/repomon

Use `-it` instead of `-d` to keep service in foreground for testing

TODO: support ssh-based authentication with `dropbear-dbclient`

## Environment variables


| Variable | Description |
| -------- | ----------- |
| `REPOSITORY_ROOT` | Path to git repository in container (default `/data`) |
| `GIT_USER` | Username used to authenticate with server |
| `GIT_PASSWORD` | Password used to authenticate with server |
| `GIT_REPO` | Repository to clone (if not already present) |
| `GIT_NAME` | Set git author and committer names to identify commits |
| `GIT_EMAIL` | Set git author and committer emails to identify commits |
| `POLL_DELAY` | Seconds between runs of the main sync routine (default `60`) |
| `COMMIT_DELAY` | After detecting local changes, this is an extra delay (in seconds) before committing and pushing the changes. This avoids "rapid fire" commits for volatile data sets. (default `900`) |
| `COMMIT_MESSAGE` | Commit message used when committing and pushing changes (default `repomon sync`) |

## Example - Compose

This compose file starts repomon with a [yegle/fava-docker](https://github.com/yegle/fava-docker) container to serve a [beancount](https://beancount.github.io/docs/index.html) repository on the local network.

```yaml
version: '3'
volumes:
  data:
services:
  repomon:
    image: 'local/repomon'
    environment:
      GIT_REPO: 'https://github.com/user/beancount.git'
      GIT_USER: 'githubuser1'
      GIT_PASSWORD: 'abc123'
      GIT_NAME: Fava
      GIT_EMAIL: 'fava@example.org'
      TZ: 'America/Chicago'
    volumes:
      - 'data:/data'
  fava:
    image: 'yegle/fava:v1.21'
    # Wait for clone before starting fava
    entrypoint: sh
    command:
      - -c
      # fava is a minimal distroless image - need python for wait/sleep loop
      - >
        echo 'import os, sys, time
        \nif not os.path.exists(os.environ["BEANCOUNT_FILE"]):
        \n  print("Missing beancount file, waiting for clone")
        \n  for x in range(60):
        \n    if os.path.exists(os.environ["BEANCOUNT_FILE"]):
        \n      sys.exit()
        \n    time.sleep(1)
        \n  sys.exit("Timed out waiting for clone")'
        | python
        && fava
    environment:
      BEANCOUNT_FILE: '/path/to/main.beancount'
    ports:
      - '5000:5000'
    volumes:
      - 'data:/data'
```
