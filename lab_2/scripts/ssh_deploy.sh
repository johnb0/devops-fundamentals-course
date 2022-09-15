#!/bin/bash

# Colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
#yel=$'\e[1;33m'
blu=$'\e[1;34m'
#mag=$'\e[1;35m'
#cyn=$'\e[1;36m'
end=$'\e[0m'

# Paths
COURSE_DIR=$HOME/work/learn/devops
BFF_HOST_DIR=$COURSE_DIR/nestjs-rest-api
BFF_HOST_BUILD_DIR=$BFF_HOST_DIR/dist
FE_HOST_DIR=$COURSE_DIR/shop-vue-vuex-cloudfront
FE_HOST_BUILD_DIR=$FE_HOST_DIR/build
WEBSERVER_HOST_DIR=/usr/local/etc/nginx/servers
WEBSERVER_HOST_CONFIG=$WEBSERVER_HOST_DIR/vue-shop.local.conf
CA_CERT_NAME=vue.server

BFF_REMOTE_DIR=/var/app/bff_app
FE_REMOTE_DIR=/var/www/fe_app
WEBSERVER_REMOTE_DIR=/etc/nginx/sites-available
WEBSERVER_REMOTE_CONFIG=vue-shop.local.conf

# Config
SSH_ALIAS=centos

build_app() {
	echo && printf "${red}Build $1 app\n${end}"
	echo && printf "${blu}Removing build folder...${end}" 
	rm -Rf $3;

	echo && printf "${blu}Building the app...${end}" && echo
	cd $2 && $4
}

check_remote_dir_exists() {
	echo && printf "${red}Check if remote directories exist${end}" && echo;

	if [[ -z $1 ]] || $1 == "/"; then
		echo "${FUNCNAME[0]}: Provide argument"
		exit;
	fi

	if ssh centos "[ ! -d $1 ]"; then
		echo "Creating: $1"
		ssh -t $SSH_ALIAS "sudo bash -c 'mkdir -p $1 && chown -R sshuser: $1'"
	else
		echo "Clearing: $1"
		ssh $SSH_ALIAS "sudo -S rm -r $1/*"
	fi
}

copy_fe_build_to_remote_server() {
	echo && printf "${red}Copying FE app${end}\n"
	scp -Crq $FE_HOST_BUILD_DIR/* $SSH_ALIAS:$FE_REMOTE_DIR
}

copy_bff_build_to_remote_server() {
	echo && printf "${red}Copying BFF app${end}\n"
	rsync -a -e ssh --exclude="node_modules" $BFF_HOST_DIR/* $SSH_ALIAS:$BFF_REMOTE_DIR
	ssh -t $SSH_ALIAS "cd $BFF_REMOTE_DIR && yarn && yarn build"
}

copy_webserver_configs() {
	echo && printf "${red}Copying webserver configs...${end}\n"
	ssh -t $SSH_ALIAS "cp -f $WEBSERVER_REMOTE_DIR/$WEBSERVER_REMOTE_CONFIG $WEBSERVER_REMOTE_DIR/$WEBSERVER_REMOTE_CONFIG.backup"
        scp -Cr $WEBSERVER_HOST_CONFIG $SSH_ALIAS:$WEBSERVER_REMOTE_DIR/$WEBSERVER_REMOTE_CONFIG	
	scp -Cr $WEBSERVER_HOST_DIR/$CA_CERT_NAME* $SSH_ALIAS:$WEBSERVER_REMOTE_DIR
}

check_remote_dir_exists $BFF_REMOTE_DIR
check_remote_dir_exists $FE_REMOTE_DIR
build_app BFF $BFF_HOST_DIR $BFF_HOST_BUILD_DIR 'yarn build'
build_app FE $FE_HOST_DIR $FE_HOST_BUILD_DIR 'yarn build'
copy_fe_build_to_remote_server
copy_bff_build_to_remote_server
copy_webserver_configs
