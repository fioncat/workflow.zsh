#!/bin/zsh

workflow_playground_create() {
	if [[ $# != 1 ]]; then
		echo "usage: workflow_playground_create <lang>"
		return 1
	fi
	local lang=$1
	read "name?Please enter the name for thie playground: "
	if [[ -z $name ]]; then
		echo "name cannot be empty"
		return 1
	fi
	local tpl_path=$WORKFLOW_HOME/.play_tpl/$lang/$name
	if [[ -d $tpl_path ]] || [[ -f $tpl_path ]]; then
		echo "The playground $name for $lang is already exists"
		return 1
	fi
	mkdir -p $tpl_path; cd $tpl_path
	case $lang in
		go)
			go mod init example/$name
			echo "package main" >> main.go
			vim main.go
			;;
		python)
			echo "print('hello')" >> main.py
			vim main.py
			;;
		*)
			echo "Unsupport language $lang, please edit your file(s) here."
			return
			;;
		# TODO: Support more languages here.
	esac
	cd -
}

workflow_playground() {
	if [[ $# -lt 1 ]] || [[ $# -gt 2 ]]; then
		echo "usage: workflow_home <lang> [<name>]"
		return 1
	fi
	local lang=$1
	if [[ $# = 2 ]]; then
		local name="$2"
	else
		local name="default"
	fi
	local tpl_path=$WORKFLOW_HOME/.play_tpl/$lang/$name
	if [[ ! -d $tpl_path ]]; then
		if [[ $name != "default" ]]; then
			echo "cannot find playground $name in $lang"
			return 1
		fi
		mkdir -p $tpl_path; cd $tpl_path
		case $lang in
			go)
				go mod init playground/default
cat <<EOT >> main.go
package main

func main() {

}
EOT
				;;
			python)
				touch main.py
				;;
			*)
				echo "We donot support $lang default template now."
				return 1
			# TODO: Support more languages here.
		esac
		echo "Create default project for $lang"
	fi
	local play_path=$WORKFLOW_HOME/play/$lang/$name
	if [[ -d $play_path ]]; then
		# FIXME: Maybe we should backup old path here?
		rm -rf $play_path
	fi
	if [[ ! -d $WORKFLOW_HOME/play/$lang ]]; then
		mkdir -p $WORKFLOW_HOME/play/$lang
	fi
	cp -rf $tpl_path $WORKFLOW_HOME/play/$lang
	cd $play_path; git init >> /dev/null
	case $lang in
		go)
			vim main.go
			;;
		python)
			vim main.py
			;;
		# TODO: Support more languages here.
	esac
}

_workflow_playground() {
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if [ "${COMP_CWORD}" = "1" ]; then
		COMPREPLY=("go" "python")
		return
	fi
	if [ "${COMP_CWORD}" = "2" ]; then
		local lang="${COMP_WORDS[1]}"
		local tpl_path=$WORKFLOW_HOME/.play_tpl/$lang
		if [[ -d $tpl_path ]]; then
			local dirs=$(ls $WORKFLOW_HOME/.play_tpl/$lang)
		fi
	fi
	COMPREPLY=($(compgen -W "${dirs}" $cur))
}

complete -F _workflow_playground workflow_playground
