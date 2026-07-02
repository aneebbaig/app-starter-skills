#!/usr/bin/env bash
# Fail if any smart punctuation shows up in text files. The output apps and this
# repo must read as human-written plain ASCII: no em or en dashes, no curly
# quotes, no ellipsis character.
set -euo pipefail

# U+2013 en dash, U+2014 em dash, U+2018/2019 curly single quotes,
# U+201C/201D curly double quotes, U+2026 ellipsis.
pattern='[\x{2013}\x{2014}\x{2018}\x{2019}\x{201C}\x{201D}\x{2026}]'

if grep -rnP "$pattern" \
    --include='*.md' --include='*.sh' --include='*.json' \
    --include='*.yml' --include='*.yaml' . ; then
  echo
  echo "Style guard failed: smart punctuation found above. Use plain ASCII"
  echo "(hyphen, straight quotes, three dots)."
  exit 1
fi

echo "Style guard passed: no smart punctuation."
