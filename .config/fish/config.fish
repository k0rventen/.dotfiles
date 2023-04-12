# envs & path
set fish_greeting 
set fish
set -xg EDITOR nano

# short aliases
alias k  'kubectl'
alias p  'python3'
alias g  'git'
alias n  'k9s --headless --crumbsless'
alias kp 'kubectl port-forward'
alias h  'hey_gpt'

# git aliases
alias gs 'git status'
alias ga 'git add'
alias gc 'git commit -m'


# dotfiles setup 
alias dotfiles "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no

# initial kubeconfig setup
test -n $OG_KUBECONFIG; and set -gx KUBECONFIG $OG_KUBECONFIG


# https://kadekillary.work/posts/1000x-eng/
# to set the key, set -U OPENAI_KEY <KEY>
function hey_gpt
    set prompt (echo $argv | string join ' ')
    set gpt (https -b post api.openai.com/v1/chat/completions \
                 "Authorization: Bearer $OPENAI_KEY" \
                 model=gpt-3.5-turbo \
                 temperature:=0.4 \
                 stream:=true \
                 messages:='[{"role": "user", "content": "'$prompt'"}]')
    for chunk in $gpt
        if test $chunk = 'data: [DONE]'
            break
        else if string match -q --regex "role" $chunk
            continue
        else if string match -q --regex "content" $chunk
            echo -n $chunk | string replace 'data: ' '' | jq -r -j '.choices[0].delta.content'
        end
    end
end

# functions
function bdec
  printf "$argv" | base64 -d
end

function benc
  printf "$argv" | base64 
end

function rand_token
  openssl rand -hex $argv | cut -c 1-$argv
end

function kctx
  if count $argv > /dev/null
    set -f new_config (find ~/.kube/configs -type f -name "$argv")
    if test -f "$new_config"
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

function kns
  if count $argv > /dev/null
    k config set-context --current --namespace $argv
  else
    k get ns
  end
end


function klogs
  if test (count $argv) -gt 1
    k logs $argv[2..] (k get pods | grep $argv[1] | awk '{print $1}')
  else 
    k logs (k get pods | grep $argv[1] | awk '{print $1}')
  end 
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
