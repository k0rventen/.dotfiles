# envs & path
set fish_greeting 
set -xg EDITOR nano

# short aliases
alias k  'kubectl'
alias p  'python3'
alias g  'git'
alias n  'k9s --headless --crumbsless'
alias kp 'kubectl port-forward'

# dotfiles setup 
alias dotfiles "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no

# functions
function bdec
  printf "$argv" | base64 -d
end

function benc
  printf "$argv" | base64 
end

function rand_token --description "create a random token of len $argv[1]"
  openssl rand -hex $argv | cut -c 1-$argv
end

if test -n $OG_KUBECONFIG
  set -gx KUBECONFIG $OG_KUBECONFIG
end

function kctx
  if count $argv > /dev/null
    set -f new_config (find ~/.kube/configs -type f -name "$argv")
    if test -n "$new_config" && test -f "$new_config"
      set -gx KUBECONFIG $new_config
      set -U OG_KUBECONFIG $new_config
      k config use-context $argv
    else
      echo "context $argv does not exists"
    end
  else 
    KUBECONFIG=(find ~/.kube/configs -type f | paste -d: -s -) kubectl config get-contexts
  end 
end

function kns --description "list and set kube namespaces"
  if count $argv > /dev/null
    k config set-context --current --namespace $argv
  else
    k get ns
  end
end


function klog --description "get logs from a pod using a pattern instead of the full pod name (eg 'klog api' instead of 'k logs api-randomchars') "
  if test (count $argv) -gt 1
    k logs  $argv[2..] (k get pods | grep $argv[1] | awk '{print $1}')
  else 
    k logs (k get pods | grep $argv[1] | awk '{print $1}')
  end 
end

function cloudcode
  if test "$argv[1]" = 'off'
    echo "stopping cloud env"
    gcloud compute instances stop sandbox
    return
  end
  echo "starting cloud code"
  gcloud compute instances start sandbox
  echo "fetching ssh infos"
  gcloud compute config-ssh
end


function git_prompt
  set git_out (git branch --show-current 2> /dev/null)
  if test $status = 0
    echo -n (set_color yellow) "("$git_out")"
  end
end


if test -d ~/.kube/configs && command -q yq
  function kube_prompt
    echo -n (set_color cyan) "["(yq '.current-context as $currctx | .contexts.[] | select(.name== $currctx) | (.name + ":" + .context.namespace)' < $KUBECONFIG)"]"
  end
else
  function kube_prompt
  end
end

function home_prompt
  echo -n (set_color magenta) (prompt_hostname)":"(prompt_pwd)
end

function command_prompt
  # previous command status
  if test $status = 0
    echo -en "\n"(set_color green)✓
  else
    echo -en "\n"(set_color red)✗
  end
  if test $CMD_DURATION -gt 1000
    echo -n " in "(math -s1 "$CMD_DURATION" / 1000)"s"
    set -g CMD_DURATION 0
  end
end

# prompt
function fish_prompt
  command_prompt
  home_prompt  
  kube_prompt
  git_prompt
  echo -e (set_color normal)"\n> "
end
