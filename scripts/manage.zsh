
workflow_update() {
	cd $WORKFLOW_HOME
	git pull
}

workflow_edit_alias() {
	vim $WORKFLOW_HOME/env/alias.zsh
}

workflow_edit_secret() {
	vim $WORKFLOW_HOME/env/secret.zsh
}
