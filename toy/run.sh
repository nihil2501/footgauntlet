#!/bin/bash

DIR="$(dirname $(readlink -f "$0"))"

while IFS= read -r line
do
  echo "$line"
  sleep 1
done \
\
< "${DIR}/input" \
| ruby "${DIR}/reverse.rb" \
| tee "${DIR}/output"
