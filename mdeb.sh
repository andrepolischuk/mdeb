#!/bin/bash

help='
  Minimal Debian packaging

  Usage
    mdeb <...files>

  Options
    --path, -p    Package installation path

  Examples
    mdeb foo.sh
    mdeb bar.sh --path /usr/local/share
'

fail() {
  echo "$*"
  exit 1
}

if ! hash dpkg jq 2>/dev/null ; then
  echo "Enter your password to install dependencies"
  sudo -v
  if [ `uname` == 'Darwin' ]; then
    brew install dpkg jq
  elif [ `uname` == 'Linux' ]; then
    sudo apt-get install dpkg jq
  else
    fail "dpkg and jq is required"
  fi
fi

package_name="$(jq -r '.name' package.json)"
package_version="$(jq -r '.version' package.json)"
package_description="$(jq -r '.description' package.json)"
package_maintainer="$(jq -r '.author' package.json)"
package_path='/usr/share'
package_files=()

while [ -n "$1" ]; do
  param="$1"
  value="$2"
  case $param in
    -h | --help)
      echo "$help"
      exit 0
      ;;
    -p | --path)
      package_path="$value"
      shift
      ;;
    *)
      package_files=("${package_files[@]}" "$param")
  esac
  shift
done

if [ -z "$package_files" ]; then
  fail 'You must specify at least one file or directory to add to the Debian package'
fi

for file in "${package_files[@]}"; do
  if ! [ -e "$file" ]; then
    fail "File does not exist: $file"
  fi
done

deb_dir="${package_name}_${package_version}_all"
deb_control_dir="$deb_dir/DEBIAN"
deb_package_dir="$deb_dir$package_path/$package_name"

echo 'Copying files into Debian directory'

mkdir -p "$deb_control_dir" "$deb_package_dir"
cp -r "${package_files[@]}" "$deb_package_dir"

echo 'Compiling templates'

template="Package: $package_name
Version: $package_version
Section: base
Priority: optional
Architecture: all
Maintainer: $package_maintainer
Description: $package_description"

echo "$template" > "$deb_control_dir/control"

echo 'Calculate md5 sums'

if hash md5sum 2>/dev/null; then
  find "$deb_dir" -path "$deb_control_dir" -prune -o -type f -print0 | xargs -0 md5sum >> "$deb_control_dir/md5sums"
elif hash md5 2>/dev/null; then
  find "$deb_dir" -path "$deb_control_dir" -prune -o -type f -print0 | {
    while IFS= read -r -d '' file; do
      echo "`md5 -q "$file"` $file" >> "$deb_control_dir/md5sums"
    done
  }
else
  fail 'md5 sum program not found'
fi

echo 'Building Debian package'

dpkg-deb --build "$deb_dir" > /dev/null
rm -rf "$deb_dir"

echo 'Package was builded successfully'
