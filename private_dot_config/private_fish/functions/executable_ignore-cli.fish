#!/bin/fish

function ignore-cli
  if test -z $argv[1]
    echo "Usage: ignore-cli <template>"
    exit 1
  else if test -e ".gitignore"
    echo "File .gitignore already exists"
    exit 1
  end

  gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /gitignore/templates/$argv[1] \
    | jq -r .source \
    > .gitignore

  if [ $status != 0 -o $pipestatus[1] != 0 ]
    echo "Failed to fetch .gitignore template"
    rm .gitignore
    exit 1
  end
end
