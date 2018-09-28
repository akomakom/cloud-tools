#!/usr/bin/env bash

function log() {
  echo "$0: $*"
}

# vendor, "version path"
function _add_toolchain() {
  version=$(echo $2 | cut -d ' ' -f 1)
  path=$(echo $2 | cut -d ' ' -f 2)
  cat <<EOF

    <toolchain>
        <type>jdk</type>
        <provides>
            <version>$version</version>
            <vendor>$1</vendor>
        </provides>
        <configuration>
            <jdkHome>$path</jdkHome>
        </configuration>
    </toolchain>
 
EOF
}

function generate_toolchains() {
  local target_file="$HOME/.m2/toolchains.xml"
  mkdir -p "$HOME/.m2"
  echo "<?xml version="1.0" encoding="UTF-8"?>" > $target_file
  echo "<toolchains>" > $target_file

  # look at the installed JDKs
   
  # First, oracle paths:
  find /usr/java -type f -name javac | grep -v jre | grep -E "[0-9]\.[0-9]" | sort | sed "s/^\(.*jdk\([0-9]\.[0-9]\)\.[0-9].*\)\/bin\/javac$/\2 \1/" | while read line ; do
    _add_toolchain "Oracle Corporation" "$line" >> $target_file
  done 
   
  # second, openjdk paths
  find /usr/lib*/jvm -type f -name javac | grep -v jre | grep -E "[0-9]\.[0-9]" | sort | sed "s/^\(.*java-\([0-9]\.[0-9]\)\.[0-9].*\)\/bin\/javac$/\2 \1/" | while read line ; do
    _add_toolchain "openjdk" "$line" >> $target_file
  done
   
  echo "</toolchains> >> $target_file
}



generate_toolchains
