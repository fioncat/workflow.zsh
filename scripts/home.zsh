#!/bin/zsh

workflow_home() {
	if [ $# -lt 1 ] || [ $# -gt 3 ]; then
		echo "usage: workflow_home <domain> [<group>] [<repo>]"
		return 1
	fi
	local domain=$1
	local src_path=$WORKFLOW_HOME/src
	local domain_path=$src_path/$domain
	if [ ! -d $domain_path ]; then
		read "ret?The domain '$domain' dose not exists, do you want to create it? (y/n) "
		if [[ $ret =~ ^[Yy]$ ]]; then
			mkdir -p $domain_path
			workflow_home_config_domain $domain
		else
			return
		fi
	fi

	if [ "$#" = "1" ]; then
		cd $domain_path
		return
	fi

	local group=$2
	local group_path=$domain_path/$group
	if [ ! -d $group_path ]; then
		read "ret?The group '$group' in '$domain' dose not exists, do you want to create it? (y/n) "
		if [[ $ret =~ ^[Yy]$ ]]; then
			mkdir -p $group_path
		else
			return
		fi
	fi

	if [ "$#" = "2" ]; then
		cd $group_path
		return
	fi

	local repo=$3
	local repo_path=$group_path/$repo
	if [ ! -d $repo_path ]; then
		read "ret?The repo '$group/$repo' in '$domain' dose not exists, do you want to create it? (y/n) "
		if [[ "$ret" != "y" ]]; then
			return
		fi

		local config_path=$WORKFLOW_HOME/.domain/$domain
		if [ ! -f $mapping_path ]; then
			echo "The config path $config_path does not exists, please run 'workflow_home_config_domain $domain'."
			return
		fi
		local domain_url=$(cat $config_path/url)
		local domain_user=$(cat $config_path/user)
		local domain_email=$(cat $config_path/email)

		read "ret?Use SSH or not? (y/n) "
		if [[ $ret =~ ^[Yy]$ ]]; then
			local clone_url="git@$domain_url:$group/$repo.git"
		else
			local clone_url="https://$domain_url/$group/$repo.git"
		fi

		read "ret?Do you want to clone this repo from VCS? (y/n) "
		if [[ $ret =~ ^[Yy]$ ]]; then
			echo "Cloning $clone_url..."
			git clone $clone_url $repo_path
			cd $repo_path
		else
			mkdir -p $repo_path; cd $repo_path
			git init
			git remote add origin $clone_url
			echo "# $repo\n" >> README.md
			read "lang?Please enter your repo type? (default empty) "
			case $lang in
				go|golang|g)
					echo "go mod init $domain_url/$group/$repo"
					go mod init $domain_url/$group/$repo
					;;
				py|python|python3|python2)
					# TODO: Python init.
					;;
				rust|rs)
					# TODO: Rust init.
					;;
				node|npm)
					# TODO: NPM init.
					;;
				*)
					echo "empty repo, do nothing."
					;;
			esac
		fi
		echo "[user]\n\tname = $domain_user\n\temail = $domain_email" >> .git/config
		return
	fi
	cd $repo_path
}

_workflow_home() {
	if [ $# -lt 1 ] || [ $# -gt 3 ]; then
		COMPREPLY=($(compgen -W "" $cur))
		return
	fi
	local src_path=$WORKFLOW_HOME/src
	if [ "${COMP_CWORD}" = "1" ]; then
		if [ -d $src_path ]; then
			local dir_list=$(ls $src_path)
		fi
	fi
	if [ "${COMP_CWORD}" = "2" ]; then
		local cur_domain="${COMP_WORDS[1]}"
		local domain_path="$src_path/$cur_domain"
		if [ -d $domain_path ]; then
			local dir_list=$(ls $domain_path)
		fi
	fi
	if [ "${COMP_CWORD}" = "3" ]; then
		local cur_domain="${COMP_WORDS[1]}"
		local cur_group="${COMP_WORDS[2]}"
		local group_path="$src_path/$cur_domain/$cur_group"
		if [ -d $group_path ]; then
			local dir_list=$(ls $group_path)
		fi
	fi
	COMPREPLY=($(compgen -W "${dir_list}" $cur))
}

complete -F _workflow_home workflow_home

# This require: tree and fzf commands.
workflow_home_search() {
	if [ "$#" != "1" ]; then
		echo 'usage: workflow_home_search <domain>'
		return 1
	fi
	local domain=$1
	local domain_path=$WORKFLOW_HOME/src/$domain
	local domain_path_escpaed=$(echo $domain_path | sed 's/\//\\\//g')
	if [ ! -d $domain_path ]; then
		echo "unknown domain $domain"
		return 1
	fi
	local dirs=("${(@f)$(tree -L 2 -fi $domain_path)}")
	local repos=()
	for (( i=0; i < ${#dirs[@]}; i++ )); do
		local dir=${dirs[i]}
		if [[ $dir == $domain_path/* ]]; then
			local dir=$(echo $dir | sed "s/$domain_path_escpaed\///1")
			if [[ $dir == *"/"* ]]; then
				repos+=("$dir")
			fi
		fi
	done
	local result=$(printf "%s\n" "${repos[@]}" | fzf)
	local repo_path=$domain_path/$result
	cd $repo_path
}

_workflow_home_search() {
	ls $WORKFLOW_HOME/src
}

complete -F _workflow_home_search workflow_home_search

workflow_home_config_domain() {
	if [ "$#" != "1" ]; then
		echo "usage: workflow_home_update_domain <domain>"
	fi
	local domain=$1
	read "domain_url?Please enter the domain url: "
	read "domain_user?Please enter the domain user: "
	read "domain_email?Please enter the domain email: "

	local config_path=$WORKFLOW_HOME/.domain/$domain
	if [ ! -d $config_path ]; then
		mkdir -p $config_path
	fi
	echo $domain_url > $config_path/url
	echo $domain_user > $config_path/user
	echo $domain_email > $config_path/email
}
