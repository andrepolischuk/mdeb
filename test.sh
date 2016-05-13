#!/bin/sh

RESET="\033[0m"
RED="\033[0;91m"
GREEN="\033[0;92m"

success() {
  echo "${GREEN}${*}${RESET}"
}

error() {
  echo "${RED}${*}${RESET}" 1>&2
}

package_name="$(jq -r '.name' package.json)"
package_version="$(jq -r '.version' package.json)"
failures=0

empty_args_test="$(./mdeb.sh)"

if [[ "$empty_args_test" != *'must specify at least one file'* ]]; then
  error 'Empty arguments test failed'
  : $((failures++))
fi

empty_files_test="$(./mdeb.sh --path /usr/local)"

if [[ "$empty_files_test" != *'must specify at least one file'* ]]; then
  error 'Empty files test failed'
  : $((failures++))
fi

wrong_file_test="$(./mdeb.sh package.json foo.js --path /usr/local)"

if [[ "$wrong_file_test" != *'File does not exist: foo.js'* ]]; then
  error 'Wrong file test failed'
  : $((failures++))
fi

success_test="$(./mdeb.sh package.json mdeb.sh --path /usr/local)"

if ! [ -s "${package_name}_${package_version}_all.deb" ]; then
  error 'Success test failed'
  : $((failures++))
fi

if [ "$failures" -eq 0 ]; then
  success 'All tests passed'
  exit 0
else
  exit 1
fi
