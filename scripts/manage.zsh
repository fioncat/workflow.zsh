
workflow_update() {
	cd $WORKFLOW_HOME
	git pull
	cd $HOME; source $WORKFLOW_HOME/init.zsh
}

workflow_edit_alias() {
	vim $WORKFLOW_HOME/env/alias.zsh
}

workflow_edit_secret() {
	vim $WORKFLOW_HOME/env/secret.zsh
}
