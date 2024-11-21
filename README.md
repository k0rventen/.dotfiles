# dotfiles

dotfiles using a bare git repo

## deploy on a sh-able machine

_(you'll need at least curl and git)_

```sh
curl -sfL https://raw.githubusercontent.com/k0rventen/.dotfiles/main/.config/setup.sh | sh
```

This will clone the repo in `$HOME` with the right options, and `checkout -f`.
__Any previous files that overlap will be overwritten !__


## prompt components

Here are all the prompt components when all the features are present:
```
✓ 7s mac-pro:~ [local-qemu:app] (main*)
> 
```
It can be decomposed as follows:
- `✓`: state of the previous command (`✗` if return code != 0)
- `7s`: time taken by the previous command (if between 1s and 1h)
- `mac-pro:~`: hostname and working dir
- `[local-qemu:app]`: current k8s context and namespace. They are per-session (see the kctx & kns wrappers below)
- `(main*)`: current git branch (`*` indicates a dirty env)
 

## functions & wrappers

- one letter aliases for git (`g`), kubectl (`k`), skaffold (`s`) and others
- two letters aliases for common command-argument combo:
  - `gs`,`ga`, `gc`,`gp`: git status/add/commit/push
  - `kp`: kubectl port-forward
  - `bdec`, `benc`: for encoding/decoding b64 payloads
- `kctx` & `kns` : functions that lists/changes your kube contexts/ns for __this__ fish session, allowing you to have different contexts on
  other sessions
- `h` function for interacting with my ollama model from the commandline
- `watch` & `repeat`: simpler version of watch & xargs.

Demo:

```
✓ mac-pro:~ [local-qemu:app]
> h how to tar a folder with gz
`tar -czf output.tar.gz folder_name`

✓ 5s mac-pro:~ [local-qemu:app]
> kctx auriga 
Found matching context in /Users/corentin/.kube/configs/auriga
Switched to context "auriga".

✓ mac-pro:~ [auriga:app]
> kns prod
Context "auriga" modified.

✓ mac-pro:~ [auriga:prod]
```


## requirements

These dotfiles are tailored for a *NIX env with the following things installed:
- fish shell
- yq & kubectl for the k8s things
- ollama `help_me / h`

## other stuff

- htop config
- httpie config
- k9s config

## usage

On a fish shell, a `dotfiles` alias will be created. It shall be used like a regular git command. 
Note that a wildcard `*` gitignore rule is used, so adding new file will require `-f`. 

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

