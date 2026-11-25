#!/usr/bin/env sh

cat ~/.local/state/shellscape/sequences.txt 2>/dev/null

exec "$@"
