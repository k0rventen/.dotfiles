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
alias m 'multipass'


# short aliases
alias kp 'kubectl port-forward'
alias gs 'git status'
alias ga 'git add'
alias gc 'git commit -m'
alias gp 'git push'
alias gd 'git diff'


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

# dotfiles setup 
alias dotfiles "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"
dotfiles config --local status.showUntrackedFiles no


# https://kadekillary.work/posts/1000x-eng/
# to set the key, set -U OPENAI_KEY <KEY>
# needs httpie and jq
if command -q https -a command -q jq
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


if command -q git
  function git_prompt
    set git_out (git branch --show-current 2> /dev/null)
    if test $status = 0
      echo -n (set_color yellow) "("$git_out")"
    end
  end
else
  function git_prompt
  end
end


# Kubernetes related functions and prompt. Only active if required binaries and files are present
if test -d ~/.kube/configs && command -q yq && command -q kubectl
# initial kubeconfig setup
  if test -n "$OG_KUBECONFIG"
    set -gx KUBECONFIG $OG_KUBECONFIG
  else
    set -U OG_KUBECONFIG (find ~/.kube/configs -type f | paste -d: -s -)
    set -gx KUBECONFIG $OG_KUBECONFIG
  end
  function kctx
    if count $argv > /dev/null
      # find the file that contains the context
      for config in (find ~/.kube/configs -type f)
        ctxname="$argv[1]" yq '.contexts.[] | .name==env(ctxname)' < $config | string match -q 'true'
        if test $status = 0
          echo "Found matching context in $config"
          set -gx KUBECONFIG $config
          set -U OG_KUBECONFIG $config
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


  function kns
    if count $argv > /dev/null
      kubectl config set-context --current --namespace $argv
    else
      kubectl get ns
    end
  end

  function kube_prompt
    echo -n (set_color cyan) "["(yq '.current-context as $currctx | .contexts.[] | select(.name== $currctx) | (.name + ":" + .context.namespace)' < $KUBECONFIG)"]"
  end
  complete -c kctx -f -a "(KUBECONFIG=(find ~/.kube/configs -type f | paste -d: -s -) kubectl config get-contexts -o name)"
  complete -c kns -f -a "(kubectl get ns -o custom-columns=name:metadata.name --no-headers)"
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
    set -f time_str "\n$(set_color green)✓"
  else
    set -f time_str "\n$(set_color red)✗"
  end
  if test $CMD_DURATION -gt 1000 -a $CMD_DURATION -lt 3600000
    set --local secs (math -s0 $CMD_DURATION/1000 % 60)
    set --local mins (math -s0 $CMD_DURATION/60000 % 60)
    set time_str $time_str" "
    test $mins -gt 0 && set time_str $time_str$mins"m"
    test $secs -gt 0 && set time_str $time_str$secs"s"
    set -g CMD_DURATION 0
  end
  echo -ne $time_str
end


# prompt
function fish_prompt
  command_prompt
  home_prompt  
  kube_prompt
  git_prompt
  echo -e (set_color normal)"\n> "
end
