#!/bin/zsh

workflow_doc() {
	if [ $# -lt 1 ] || [ $# -gt 2 ]; then
		echo "usage: workflow_doc <group> [<op>]"
		return 1
	fi
	local group=$1
	local doc_path=$WORKFLOW_HOME/doc/$group
	if [ ! -d $doc_path ]; then
		read "ret?The doc group $group dose not exists, do you want to create it? (y/n) "
		if [[ $ret =~ ^[Yy]$ ]]; then
			mkdir -p $doc_path
		else
			return
		fi
	fi
	if [ $# = 2 ]; then
		local op=$2
	fi
	case $op in
		open|o)
			# TODO: This is only useful in mac, requires Linux adaptation.
			open $doc_path
			;;

		code|c)
			# Need to install VSCode and its shell command "code".
			code $doc_path
			;;
		vim|v)
			vim
			;;
		*)
			cd $doc_path
			;;
	esac
}

_workflow_doc() {
	local cur="${COMP_WORDS[COMP_CWORD]}"
	if [ "${COMP_CWORD}" = "1" ]; then
		local words=$(ls $WORKFLOW_HOME/doc)
	fi
	if [ "${COMP_CWORD}" = "2" ]; then
		COMPREPLY=("open" "code" "vim")
		return
	fi
	COMPREPLY=($(compgen -W "${words}" $cur))
}

complete -F _workflow_doc workflow_doc
