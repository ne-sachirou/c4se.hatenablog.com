#!/bin/bash -eux
if [[ -n ${2:-} ]] ; then
  ag -l $1 | xargs -t -I{} sed -i -e "s/$1/$2/g" {}
  git diff
  echo "git add -p && git commit -m 's/$1/$2/'"
else
  ag $1
fi