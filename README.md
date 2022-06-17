# workflow.zsh

## Install

We have some basic requirements for using the commands:

- [fzf](): For searching.
- tree: This command maybe not be provided by some OS, for example, in Mac, you can install it throught `brew install tree`.
- VSCode: The command `workflow_doc` need it, you should install the VSCode's CLI `code` in your shell env.

Then you can install `workflow.zsh`:

```shell
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/fioncat/workflow.zsh/master/install.zsh)"
```

## QuickStart

Use the command to create a new domain, like `Github`:

```shell
wh github
```

The command will ask for you some information, like user, email, etc.

Then, you can clone a repository from the remote VCS or create an empty one by using:

```shell
wh github <group> <repo>
```

The next time, you can use zsh's completion to complete the repository's group and name quickly:

```shell
wh github <TAB> <TAB> # The command has a full support for zsh completion.
```

