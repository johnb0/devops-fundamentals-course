#!/bin/bash - 
#===============================================================================
#
#          FILE: quality-check.sh
# 
#         USAGE: ./quality-check.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Andrey Korolev (Developer), andrey_korolev@epam.com
#  ORGANIZATION: Ecommerce
#       CREATED: 08/08/2022 05:01:36 PM
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error

declare SCRIPT_DIR=$(dirname $(realpath $0))
declare REPO_DIR="$(dirname $SCRIPT_DIR)/shop-angular-cloudfront"
declare PACKAGE_MANAGER=yarn # could be yarn or npm

runChecks ()
{
	cd $REPO_DIR
	npm run lint
	npm run test
	npm audit
}	# ----------  end of function runChecks  ----------

main ()
{
	runChecks	
}	# ----------  end of function main  ----------

main
