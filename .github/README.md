# dotfiles

dotfiles repo using a bare git repo

## deploy on a sh-able machine

```sh
curl -sfL https://raw.githubusercontent.com/k0rventen/.dotfiles/main/.config/setup.sh | sh
```

This will clone the repo with the right options, and `checkout -f`.
Any previous files that overlap will be overwritten !


## features

- one letter aliases for git (`g`), kubectl (`k`), skaffold (`s`) and others,
- `kctx` & `kns` : functions that lists/changes your kube contexts/ns for __this__ fish session, allowing you to have different contexts on other sessions
- `hey_gpt` function for interacting with ChatGPT from the commandline
- a prompt that shows concise, useful information

Demo:

```
✓ in 1s mac:~/dev/proj [microk8s:default] (main)
> 
```


## requirements

These dotfiles are tailored for a *NIX env with the following things installed:
- fish shell
- yq & kubectl for the k8s things
- jq, httpie and an OPENAI API key for `hey_gpt`


## usage

On a fish shell, a `dotfiles` alias will be created. It shall be used like a regular git command. 
Note that a wildcard `*` .gitignore is used, so adding new file will require `-f`. 

Here is an example of adding a new file:
```
dotfiles add -f .config/conf.conf
dotfiles commit -m "add conf for conf"
dotfiles push
```

## inspiration & further links

- https://www.atlassian.com/git/tutorials/dotfiles
- https://dotfiles.github.io/
- https://www.reddit.com/r/unixporn/top/?t=week

