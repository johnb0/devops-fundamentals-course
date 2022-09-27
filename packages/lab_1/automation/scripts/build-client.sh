#!/bin/bash - 
#===============================================================================
#
#          FILE: build-client.sh
# 
#         USAGE: ./build-client.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Andrey Korolev (Developer), andrey_korolev@epam.com
#  ORGANIZATION: Ecommerce
#       CREATED: 08/08/2022 03:15:54 PM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

declare SCRIPT_DIR=$(dirname $(realpath $0))
declare REPO_DIR="$(dirname $SCRIPT_DIR)/shop-angular-cloudfront"
declare PACKAGE_MANAGER=yarn # could be yarn or npm
declare ZIP_TOOL=zip # for windows it would be 7z
declare DIST_DIR="${REPO_DIR}/dist"
declare DIST_APP_DIR="${DIST_DIR}/app"
declare DIST_ARCHIVE="${DIST_DIR}/client-app.zip"

installDeps ()
{
	cd $REPO_DIR
	$PACKAGE_MANAGER install 
}	# ----------  end of function installDeps  ----------

build ()
{
	CONFIG=${ENV_CONFIGURATION:-}

	if [[ -z $CONFIG ]];
	then
		echo '$ENV_CONFIGURATION is not defined. Development mode is used by default'
	fi;

	$PACKAGE_MANAGER build --configuration $CONFIG 
}	# ----------  end of function build  ----------

compress ()
{
	if [[ -e $DIST_ARCHIVE ]];
	then
		rm -f $DIST_ARCHIVE
		echo "Old $DIST_ARCHIVE was deleted"
	fi;

	$ZIP_TOOL -r $DIST_ARCHIVE $DIST_APP_DIR 
	echo "$DIST_ARCHIVE has been created"
}	# ----------  end of function compress  ----------

main ()
{
	installDeps
	build
	compress
}	# ----------  end of function main  ----------

main
