#!/usr/bin/env bash

function log() {
  echo "$0: $*"
}

# vendor, version, path
function _add_toolchain() {
  cat <<EOF

    <toolchain>
        <type>jdk</type>
        <provides>
            <version>$2</version>
            <vendor>$1</vendor>
        </provides>
        <configuration>
            <jdkHome>$3</jdkHome>
        </configuration>
    </toolchain>
 
EOF
}

function generate_toolchains() {
  local target_file="$HOME/.m2/toolchains.xml"
  mkdir -p "$HOME/.m2"
  echo "<?xml version="1.0" encoding="UTF-8"?>" > $target_file
  echo "<toolchains>" >> $target_file

  # look at the installed JDKs
   
  # oracle paths:
  find /usr/java -type f -name javac | grep -v jre | grep -E "[0-9]\.[0-9]" | sort | sed "s/^\(.*jdk\([0-9]\.[0-9]\)\.[0-9].*\)\/bin\/javac$/\2 \1/" | while read line ; do
    _add_toolchain 'Oracle Corporation' $line >> $target_file
  done 
   
  # openjdk paths
  find /usr/lib*/jvm -type f -name javac | grep -v jre | grep -E "[0-9]\.[0-9]" | sort | sed "s/^\(.*java-\([0-9]\.[0-9]\)\.[0-9].*\)\/bin\/javac$/\2 \1/" | while read line ; do
    _add_toolchain openjdk $line >> $target_file
  done
  
  # zulu paths:
  find /usr/lib*/jvm -type f -name javac | grep -v jre | grep -E -- "zulu-" | sort | sed "s/^\(.*zulu-\([^/]*\)\)\/bin\/javac$/1.\2 \1/" | while read line ; do
    _add_toolchain zulu $line >> $target_file
  done
  
  # ubuntu style
  find /usr/lib*/jvm -type f -name javac | grep -E -- "-[0-9]-" | sort | sed 's|^\(.*java-\([0-9]\)-\([^/^-]*\).*\)\/bin\/javac$|\3 1.\2 \1|' | while read line ; do
    # returns "vendor version path"
    _add_toolchain $line
  done
  
  echo "</toolchains>" >> $target_file
  
  cat $target_file
  
  # debug
  find /usr/lib/jvm* -type f -name javac
}



generate_toolchains
