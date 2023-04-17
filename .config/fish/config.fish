# envs & path
set fish_greeting 
set -xg EDITOR nano

# very short aliases
alias k 'kubectl'
alias p 'python3'
alias g 'git'
alias n 'k9s --headless --crumbsless'
alias h 'hey_gpt'
alias s 'skaffold'

# short aliases
alias kp 'kubectl port-forward'
alias gs 'git status'
alias ga 'git add'
alias gc 'git commit -m'
alias gp 'git push'


# dotfiles setup 
alias dotfiles "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no


# https://kadekillary.work/posts/1000x-eng/
# to set the key, set -U OPENAI_KEY <KEY>
# needs httpie and jq
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


# kubernetes related function 


# initial kubeconfig setup
if test -n "$OG_KUBECONFIG"
  set -gx KUBECONFIG $OG_KUBECONFIG
else if test -d ~/.kube/configs
  set -U OG_KUBECONFIG (find ~/.kube/configs -type f | paste -d: -s -)
  set -gx KUBECONFIG $OG_KUBECONFIG
end

function kctx
  if count $argv > /dev/null
    # find the file that contains the context
    for config in (find ~/.kube/configs -type f)
      ctxname="$argv[1]" yq '.contexts.[] | .name==env(ctxname)' < $config | string match -q 'true'
      if test $status = 0
        set -gx KUBECONFIG $config
        set -U OG_KUBECONFIG $config
        echo 'Found matching context in '$config
        kubectl config use-context $argv
        return
      end
    end
    echo 'No matching context found..'
  else 
    # print out all the contexts
    KUBECONFIG=(find ~/.kube/configs -type f | paste -d: -s -) kubectl config get-contexts
  end 
end

complete -c kctx -f -a "(KUBECONFIG=(find ~/.kube/configs -type f | paste -d: -s -) kubectl config view | yq '.contexts.[] | .name')"

function kns
  if count $argv > /dev/null
    kubectl config set-context --current --namespace $argv
  else
    kubectl get ns
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
