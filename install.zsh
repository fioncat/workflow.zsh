#!/bin/zsh

read "wf_home?Where do you want to install workflow.zsh ? (default ~/dev) "
if [ -z $wf_home ]; then
	local wf_home="$HOME/dev"
fi

local wf_home=$(echo $wf_home | sed 's/~/\$HOME/g')
eval wf_home="$wf_home"

if [ -d $wf_home ]; then
	echo "The path $wf_home already exists, please backup or remove it first."
	return 1
fi

git clone --depth 1 https://github.com/fioncat/workflow.zsh.git $wf_home
mkdir -p $wf_home/env

cat <<EOT >> $wf_home/env/alias.zsh
# Define your custom alias here.

alias wh="workflow_home"
EOT

cat <<EOT >> $wf_home/env/secret.zsh
# Define your secret content (like password, token) here.

EOT

echo "Congratulations! You have workflow.zsh installed in your machine."
echo "Please add the following script to your .zshrc to continue:"
echo ""
echo "    source $wf_home/init.zsh"
echo ""
