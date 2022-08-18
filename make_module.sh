#!/bin/sh

# -- Download latest 'update-binary'
echo "Download latest 'update-binary'..."
bin_file=./META-INF/com/google/android/update-binary
sed -n '/http[s]*/ s|/blob/|/raw/|p' $bin_file | cut -f2 -d' ' | xargs curl -Lso $bin_file
unset bin_file

# -- Make module
echo "Make module..."
MODULE_PROP=./module.prop
ID=`grep "id=" $MODULE_PROP | cut -d= -f2`
VERSION=`grep "version=" $MODULE_PROP | cut -d= -f2`

zip -9r ${ID}-${VERSION}.zip CHANGELOG customize.sh LICENSE module.prop README.md "system/" "META-INF/"
