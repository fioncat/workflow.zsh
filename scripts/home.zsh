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

		read "ret?Use SSH or not? (y/n) "
		if [[ $ret =~ ^[Yy]$ ]]; then
			local clone_url="git@$domain_url:$group/$repo.git"
		else
			local clone_url="https://$domain_url/$group/$repo.git"
		fi

		local config_path=$WORKFLOW_HOME/.domain/$domain
		if [ ! -f $mapping_path ]; then
			echo "The config path $config_path does not exists, please run 'workflow_home_config_domain $domain'."
			return
		fi
		local domain_url=$(cat $config_path/url)
		local domain_user=$(cat $config_path/user)
		local domain_email=$(cat $config_path/email)

		read "ret?Do you want to clone this repo from VCS? (y/n) "
		if [[ $ret =~ ^[Yy]$ ]]; then
			echo "Clone $clone_url..."
			git clone $clone_url $repo_path
			cd $repo_path
		else
			# TODO: init the repo according to different languages.
			mkdir -p $repo_path; cd $repo_path
			git init
			git remote add origin $clone_url
		fi
		echo "[user]\n\tname = $domain_user\n\temail = $domain_email" >> .git/config
	fi
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
