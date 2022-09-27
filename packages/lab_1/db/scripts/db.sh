#!/bin/bash - 
#===============================================================================
#
#          FILE: db.sh
# 
#         USAGE: ./db.sh 
# 
#   DESCRIPTION: 
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Andrey Korolev (Developer), andrey_korolev@epam.com
#  ORGANIZATION: Ecommerce
#       CREATED: 08/04/2022 12:37:53 PM
#      REVISION:  ---
#===============================================================================

set -e 
set -u
set -o nounset                              # Treat unset variables as an error

declare DBFILE=user.db
declare SCRIPTPATH=$(dirname $(realpath $0))
declare DBDIR="$(dirname $SCRIPTPATH)/data"
declare DBPATH="$DBDIR/$DBFILE"

backup ()
{
	local BACKUP="$(date +%s)-$DBFILE.backup"

	cp $DBPATH "$DBDIR/$BACKUP"
	echo "$BACKUP file was created"
}	# ----------  end of function backup  ----------


restore ()
{
	local LATEST_BACKUP=$(ls $DBDIR | grep ".backup" | sort | tail -n 1)
	
	if [[ -z $LATEST_BACKUP ]];
	then
		echo "No backups"
	else
		cp -f "$DBDIR/$LATEST_BACKUP" "$DBDIR/$DBFILE"
		echo "Backup was restored"
	fi
}	# ----------  end of function restore  ----------

validate ()
{
	if [[ $1 =~ ^[A-Za-z]+$ ]]; then return 0; else return 1; fi
}

add ()
{
	read -p "Enter username: " username

	if $(validate $username); 
	then
		read -p "Enter role: " role

		if $(validate $role);
		then
			echo "$username, $role" >> $DBPATH 
			echo "User was added"
		else
			echo "Role should contain only latin latters"
			add
		fi
	else
		echo "Username should contain only latin latters"
		add
	fi
}	# ----------  end of function add  ----------


find ()
{
	read -p "Type username to find: " searchterm

	local userfound="$(egrep -w ^$searchterm $DBPATH)"

	if [[ -z $userfound ]];
	then 
		echo
		echo "User was not found"
	else
		echo
		echo "$userfound"
	fi
}	# ----------  end of function find  ----------


list ()
{
    if [[ $inverse == "inverse" ]]
    then
      cat --number $DBPATH | tac
    else
      cat --number $DBPATH
    fi
}	# ----------  end of function list  ----------


help ()
{
	echo "Manages users in db. It accepts a single parameter with a command name."
	echo
	echo "Syntax: db.sh [command]"
	echo
	echo "List of available commands:"
	echo
	echo "add       Adds a new line to the users.db. Script must prompt user to type a
									username of new entity. After entering username, user must be prompted to
									type a role."
	echo "backup    Creates a new file, named" $DBPATH".backup which is a copy of
									current" $DBPATH
	echo "find      Prompts user to type a username, then prints username and role if such
									exists in users.db. If there is no user with selected username, script must print:
									“User not found”. If there is more than one user with such username, print all
									found entries."
	echo "list      Prints contents of users.db in format: N. username, role
									where N – a line number of an actual record
									Accepts an additional optional parameter inverse which allows to get
									result in an opposite order – from bottom to top"
}	# ----------  end of function help  ----------


main ()
{
	if [[ "$1" != "help" && "$1" != "" && ! -f  $DBPATH ]];
	then
		read -p "$DBPATH doesn't exist. Would you like me to create it? [Y|n] " answer;
		answer=${answer,,} # make the answer in lowercase

		if [[ $answer =~ ^(yes|y)$ ]] ; then
			touch $DBPATH;
			echo "File $DBPATH has been created";
		else
			echo "$DBPATH must be created before proceed"
			exit 1
		fi
	fi

	case $1 in 
		backup)		backup ;;
		restore)	restore ;;
		add)			add ;;
		find)			find ;;
		list)
			if [[ $# -eq 2 ]];
			then
				inverse="$2";
			else
				inverse="";
			fi

			list
			;;
		help | '' | *) help ;;
	esac
}	# ----------  end of function main  ----------

main $*


