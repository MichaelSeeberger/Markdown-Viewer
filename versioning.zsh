#!/bin/zsh

PRODUCT_NAME="Markdown Viewer"
cd "${PRODUCT_NAME}"
touch "${PRODUCT_NAME}-Info.plist"
buildVersion=`git log --oneline | wc -l`
echo "#define BUILD_VERSION ${buildVersion}" > "InfoPlist.h"
