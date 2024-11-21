cd $HOME

echo "cloning dotfiles directory.."
git clone --bare https://github.com/k0rventen/.dotfiles.git .dotfiles

echo "checking out files !"
git --git-dir=.dotfiles/ --work-tree=$HOME checkout -f

echo "setting ignore rules"
echo "*" >> .dotfiles/info/exclude
git --git-dir=.dotfiles/ --work-tree=$HOME update-index --skip-worktree README.md
rm README.md

echo "dotfiles are now installed !"
