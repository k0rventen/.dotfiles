cd $HOME
echo "cloning dotfiles directory.."
git clone --bare https://github.com/k0rventen/.dotfiles.git .dotfiles
echo "checking out files !"
git --git-dir=.dotfiles/ --work-tree=$HOME checkout -f
echo "dotfiles are now installed !"
