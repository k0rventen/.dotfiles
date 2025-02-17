# envs & path
set fish_greeting
set -xg EDITOR nano
set -xg LSCOLORS gxfxcxdxbxegedabagacad
set -xg LS_COLORS 'di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
set -xg TERM xterm
set -xg HOMEBREW_NO_AUTO_UPDATE 1


# very short aliases and functions
alias k 'kubectl'
alias p 'python3'
alias b 'brew'
alias d 'docker'
alias g 'git'
alias n 'k9s --headless --crumbsless'
alias t 'tmux -f ~/.config/tmux.conf'
function o; count $argv > /dev/null; and open $argv; or open . ;end
function z; count $argv > /dev/null; and flatpak run dev.zed.Zed -a $argv; or flatpak run dev.zed.Zed -a . ;end


# short aliases
alias kp 'kubectl port-forward'
alias kl 'kubectl logs'
alias ky 'kubectl --output=yaml'
alias kj 'kubectl --output=json'
alias dc 'docker compose'

# git aliases
alias gs 'git status'
alias ga 'git add'
alias gu 'git restore --staged'
alias gp 'git push'
alias gd 'git diff'

function gb
  git branch | grep ' '$argv'$' > /dev/null; and git checkout $argv; or git checkout -b $argv
end
complete -c gb -f -a "(git branch --format='%(refname:strip=2)')"

function gc
    count $argv > /dev/null; and git commit -m "$argv"; or git commit --amend --no-edit .
end



# quick containers
alias alp 'd run -it -w /data -v .:/data alpine sh'
alias deb 'd run -it -w /data -v .:/data debian bash'



# colors
set -U fish_color_autosuggestion e4e4e4
set -U fish_color_cancel --reverse
set -U fish_color_command 5fffff
set -U fish_color_comment bcbcbc
set -U fish_color_cwd 73D0FF
set -U fish_color_cwd_root red
set -U fish_color_end F29E74
set -U fish_color_error FF3333
set -U fish_color_escape 95E6CB
set -U fish_color_history_current --bold
set -U fish_color_host normal
set -U fish_color_host_remote
set -U fish_color_keyword
set -U fish_color_match F28779
set -U fish_color_normal CBCCC6
set -U fish_color_operator FFCC66
set -U fish_color_option
set -U fish_color_param CBCCC6
set -U fish_color_quote BAE67E
set -U fish_color_redirection af87ff
set -U fish_color_search_match --background=FFCC66
set -U fish_color_selection --background=FFCC66
set -U fish_color_status red
set -U fish_color_user brgreen
set -U fish_color_valid_path --underline
# git prompt setup
set -g __fish_git_prompt_show_informative_status 1
set -g __fish_git_prompt_char_dirtystate '*'
set -g __fish_git_prompt_char_stagedstate '+'
set -g __fish_git_prompt_char_stashstate '$'
set -g __fish_git_prompt_char_untrackedfiles '%'
set -g __fish_git_prompt_char_cleanstate '='

# dotfiles setup
alias dots "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
if command -q ansible-playbook
  alias config "ANSIBLE_LOCALHOST_WARNING=False ANSIBLE_INVENTORY_UNPARSED_WARNING=False ansible-playbook $HOME/.config/config.yaml -K"
  alias config-upgrade "config -e upgrade=true"
end

# inspired by https://kadekillary.work/posts/1000x-eng/
# but runs locally using ollama
if command -q ollama
  function h --description "talk to your sidekick engineer"
      ollama run devops "$argv"
  end
end


# decode b64 from stdin
function bdec
  printf "$argv" | base64 -d
end

# encode to b64 from stdin
function benc
  printf "$argv" | base64
end

# create a random hex of len $argv
function rand_token
  cat /dev/urandom | tr -dc '[:alnum:]' | head -c $argv
end

# like watch -n2, but herits from aliases, functions and env vars
function repeat
  echo -e "Running '$argv' continuously at 2s interval."
  while :
    eval $argv
    sleep 2
  end
end

# run a command for each line from stdin. use placeholder {} in command, eg.  cat file | foreach echo 'hey {}'
function foreach
  string match '*{}*' $argv > /dev/null
  if test $status != 0
    echo "missing {} in argument"
    return
  end
  while read line
    set cmd (string replace "{}" "$line" "$argv")
    eval $cmd
  end
end

# automatically runs sudo -i right after login
function sshu
  set ssh_target $argv
  set psswd (read -s -P "ssh password:")
  set expect_tmpl '''
    set timeout 5
    # ssh to the target
    spawn ssh __ssh_target__

    # enter ssh password
    expect "password:"
    send "__ssh_pass__\r"

    # w8 for login banner and prompt
    expect  -re ".*"
    sleep 0.5
    # re enter password for sudo if necessary
    send "sudo -i\r"
    expect {
            "password for" {send "__ssh_pass__\r";interact}
            -re ".*" interact
    }
   '''
  expect -f (string replace -a __ssh_pass__ $psswd (string replace __ssh_target__ $argv $expect_tmpl) | psub)

end

# Kubernetes related functions and prompt. Only active if required binaries and files are present
if test -d ~/.kube/configs && command -q yq && command -q kubectl
# initial kubeconfig setup
  if test -n "$OG_KUBECONFIG"
    set -gx KUBECONFIG $OG_KUBECONFIG
  else
    set -Ux OG_KUBECONFIG (find ~/.kube/configs -type f | paste -d: -s -)
    set -gx KUBECONFIG $OG_KUBECONFIG
  end

  # per session kube context switcher
  function kctx
    if count $argv > /dev/null
      # find the file that contains the context
      for config in (find ~/.kube/configs -type f)
        ctxname="$argv[1]" yq '.contexts.[] | .name==env(ctxname)' < $config | string match -q 'true'
        if test $status = 0
          echo "Found matching context in $config"
          set -gx KUBECONFIG $config
          set -Ux OG_KUBECONFIG $config
          kubectl config use-context $argv
          return
        end
      end
      echo 'No matching context found.'
    else
      # print out all the contexts
      KUBECONFIG=(find ~/.kube/configs -type f | paste -d: -s -) kubectl config get-contexts -o name
    end
  end

  # namespace switcher
  function kns
    if count $argv > /dev/null
      kubectl config set-context --current --namespace $argv
    else
      kubectl get ns
    end
  end

  # prompt showing context:namespace
  function kube_prompt
    echo -n (set_color cyan) "["(yq '.current-context as $currctx | .contexts.[] | select(.name== $currctx) | (.name + ":" + .context.namespace)' < $KUBECONFIG)"]"
  end

  # autocompletion
  complete -c kctx -f -a "(KUBECONFIG=(find ~/.kube/configs -type f | paste -d: -s -) kubectl config get-contexts -o name)"
  complete -c kns -f -a "(kubectl get ns -o custom-columns=name:metadata.name --no-headers)"
else
  # empyt func if not kubectl
  function kube_prompt
  end
end


function home_prompt
  echo -n (set_color magenta) (prompt_hostname)":"(prompt_pwd)
end

function command_prompt
  # previous command status + time taken if > 1s < 1h
  if test $status = 0
    set -f time_str "\n$(set_color green)✓"
  else
    set -f time_str "\n$(set_color red)✗"
  end
  if test $CMD_DURATION -gt 1000 -a $CMD_DURATION -lt 3600000
    set -l secs (math -s0 $CMD_DURATION/1000 % 60)
    set -l mins (math -s0 $CMD_DURATION/60000 % 60)
    set time_str $time_str" "
    test $mins -gt 0 && set time_str $time_str$mins"m"
    test $secs -gt 0 && set time_str $time_str$secs"s"
    set -g CMD_DURATION 0
  end
  echo -ne $time_str
end


# automatic repaint of the prompt
# function __trigger_prompt_sync --on-event fish_prompt
#   set -U __prompt_sync (date)
# end

# function __prompt_sync --on-variable __prompt_sync
#   test (date) = $__prompt_sync; or return
#   commandline -f repaint
# end


# prompt
function fish_prompt
  history merge
  command_prompt
  home_prompt
  kube_prompt
  fish_git_prompt
  echo -e (set_color normal)"\n> "
end
