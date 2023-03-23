# dotfiles

dotfiles repo using a bare git repo

## deploy on a sh-able machine

```sh
curl -sfL https://raw.githubusercontent.com/k0rventen/.dotfiles/main/.config/setup.sh | sh
```

This will clone the repo with the right options, and `checkout -f`.
Any previous files that overlap will be overwritten !


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

