cd $HOME
git clone --bare https://github.com/k0rventen/.dotfiles.git .dotfiles
git --git-dir=.dotfiles/ --work-tree=$HOME checkout
