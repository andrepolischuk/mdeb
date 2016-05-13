#!/bin/bash

fail() {
  echo "$*" 1>&2
}

package_name="$(jq -r '.name' package.json)"
package_version="$(jq -r '.version' package.json)"
failures=0

empty_args_test="$(./mdeb.sh)"

if [[ "$empty_args_test" != *'must specify at least one file'* ]]; then
  fail 'Empty arguments test failed'
  : $((failures++))
fi

empty_files_test="$(./mdeb.sh --path /usr/local)"

if [[ "$empty_files_test" != *'must specify at least one file'* ]]; then
  fail 'Empty files test failed'
  : $((failures++))
fi

wrong_file_test="$(./mdeb.sh package.json foo.js --path /usr/local)"

if [[ "$wrong_file_test" != *'File does not exist: foo.js'* ]]; then
  fail 'Wrong file test failed'
  : $((failures++))
fi

success_test="$(./mdeb.sh package.json mdeb.sh --path /usr/local)"

if ! [ -s "${package_name}_${package_version}_all.deb" ]; then
  fail 'Success test failed'
  : $((failures++))
fi

if [ "$failures" -eq 0 ]; then
  echo 'All tests passed'
else
  exit 1
fi
