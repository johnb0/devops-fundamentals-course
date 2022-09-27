#!/bin/bash - 
#===============================================================================
#
#          FILE: update-pipeline-definition.sh
# 
#         USAGE: ./update-pipeline-definition.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Andrey Korolev (Developer), andrey_korolev@epam.com
#  ORGANIZATION: Ecommerce
#       CREATED: 08/08/2022 05:34:55 PM
#      REVISION:  ---
#===============================================================================

SOURCE_FILE=unset
CONFIG=
OWNER=
BRANCH=develop
POLL=no
REPO=

formatJson ()
{
  cat $SOURCE_FILE | jq --arg branch "$BRANCH" \
    --arg owner "$OWNER" \
    --arg config "$CONFIG" \
    --arg poll "$POLL" \
    --arg repo "$REPO" \
    'del(.metadata) | .pipeline.version |= .+1 | (.pipeline.stages[] | select(.name == "Source") | .actions[] | select(.name = "Source") | .configuration) |= . + {Branch: $branch, Owner: $owner, Repo: $repo, PollForSourceChanges: $poll} | (.pipeline.stages[].actions[] | .configuration.EnvironmentVariables) |= ([{name: "BUILD_CONFIGURATION", value: $config, type: "PLAINTEXT"}] | tostring)' > "pipeline-$(date +%s).json" 
}

checkJQ() {
  type jq >/dev/null 2>&1

  exitCode=$?

  if [ "$exitCode" -ne 0 ]; then
    printf "'jq' not found! (json parser)\n"
    printf "    MacOS Installation:  https://jira.amway.com:8444/display/CLOUD/Configure+PowerShell+for+AWS+Automation#ConfigurePowerShellforAWSAutomation-MacOSSetupforBashScript\n"
    printf "    Ubuntu Installation: sudo apt install jq\n"
    printf "    Redhat Installation: sudo yum install jq\n"

    printf "Missing 'jq' dependency, exiting.\n"
    exit 1
  fi
}

wizard() {
  read -p '> Please, enter the pipeline’s definitions file path (default: pipeline.json): ' SOURCE_FILE
  read -p '> Which BUILD_CONFIGURATION name are you going to use (default: “”): ' CONFIG
  read -p '> Enter a GitHub owner/account: ' OWNER
  read -p '> Enter a GitHub repository name: ' REPO
  read -p '> Enter a GitHub branch name (default: develop): ' BRANCH
  read -p '> Do you want the pipeline to poll for changes (yes/no) (default: no)?: ' POLL
  read -p '> Do you want to save changes (yes/no) (default: yes)?: ' SAVE 

  if [[ $SAVE == 'yes' || $SAVE == '' ]];
  then
    formatJson
  fi

  exit 2
}

checkJQ

SOURCE_FILE=$1

if [[ -z $SOURCE_FILE || ! -e $SOURCE_FILE ]];
then
  "Source file is missing"
  exit 1
fi

if [[ $# -eq 1 ]];
then
  wizard
fi

PARSED_ARGUMENTS=$(getopt -a -n $0 --long configuration:,owner:,branch:,poll-for-source-changes:,repo: -- $@)
VALID_ARGUMENTS=$?

if [ "$VALID_ARGUMENTS" != "0" ]; 
then
  wizard  
else
  eval set -- "$PARSED_ARGUMENTS"
  while :
    do
      case "$1" in
        --configuration)    CONFIG="$2"; shift 2 ;;
        --owner)            OWNER="$2"; shift 2 ;;
        --branch)           BRANCH="$2"; shift 2 ;;
        --poll-for-source-changes)             POLL="$2"; shift 2 ;;
        --repo)             REPO="$2"; shift 2 ;;
        --) shift; break ;;
        # If invalid options were passed, then getopt should have reported an error,
        # which we checked as VALID_ARGUMENTS when getopt was called...
        *) echo "Unexpected option: $1 - this should not happen."
           echo wizard ; break;;
      esac
  done

  formatJson
fi

exit 0

