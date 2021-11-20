#!/bin/sh

# -- Make module
echo "Make module..."
MODULE_PROP=./module.prop
ID=`grep "id=" $MODULE_PROP | cut -d= -f2`
VERSION=`grep "version=" $MODULE_PROP | cut -d= -f2`

zip -9r ${ID}-${VERSION}.zip CHANGELOG customize.sh LICENSE module.prop README.md service.sh "META-INF/"
