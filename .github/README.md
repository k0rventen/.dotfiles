# dotfiles

dotfiles repo using a bare git repo

## deploy on a sh-able machine

```sh
curl -sfL https://raw.githubusercontent.com/k0rventen/.dotfiles/main/.config/setup.sh | sh
```

This will clone the repo with the right options, and `checkout -f`.
Any previous files that overlap will be overwritten !


## prompt components

Here are all the prompt components when all the features are present:
```
✓ 7s mac-pro:~ [local-qemu:app] (main)
> 
```
It can be decomposed as follows:
- `✓`: state of the previous command (`✗` if return code != 0)
- `7s`: time taken by the previous command (if more than 1 second)
- `mac-pro:~`: hostname:working dir
- `[local-qemu:app]`: current k8s context and namespace. They are per-session (see the kctx & kns wrappers below)
- `(main)`: current git branch 


## functions & wrappers

- one letter aliases for git (`g`), kubectl (`k`), skaffold (`s`) and others
- two letters aliases for common command-argument combo:
  - `gs`,`ga`, `gc`,`gp`: git status/add/commit/push
  - `kt`,`kp`: kubectl top/port-forward
  - `bdec`, `benc`: for encoding/decoding b64 payloads
- `kctx` & `kns` : functions that lists/changes your kube contexts/ns for __this__ fish session, allowing you to have different contexts on
  other sessions
- `hey_gpt` function for interacting with ChatGPT from the commandline

Demo:

```
> hey_gpt write a short poem about kubernetes
Kubernetes, oh Kubernetes
A master of orchestration
Scaling apps with ease and grace
In the cloud, a true sensation

From pods to nodes, it manages all
A container's best friend
With automation and control
It keeps our workloads in trend

A tool for DevOps, a boon for IT
Kubernetes, we sing your praise
With you by our side, we're unstoppable
In the cloud, we'll forever blaze.

✓ 7s mac-pro:~ [local-qemu:app]
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
- jq, httpie and an OPENAI API key for `hey_gpt`

## other stuff

- htop config
- httpie config
- backup script using rsync

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

