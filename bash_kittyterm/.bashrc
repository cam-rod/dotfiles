# Not a full bashrc, just additions

### ...set user PATH ###

source <(op completion bash)
alias chrome=google-chrome-stable
alias lso='ls -lash --time-style=long-iso'
alias ssk='kitty +kitten ssh'

# Scripts
export PATH="$PATH:$HOME/scripts" # For all the scripting fun
alias colocat="python3 $HOME/scripts/colocat.py"
alias colodiff="python3 $HOME/scripts/colodiff.py"
alias git-unsync="python3 $HOME/scripts/git-unsync.py"
alias ynab-csv="python3 $HOME/scripts/ynab-csv.py"

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --reload gpg-agent
gpg-connect-agent 'updatestartuptty' /bye >/dev/null # Don't call on remote SSH servers

export EDITOR='/usr/bin/vim -e'
export VISUAL=/usr/bin/vim
export KITTY_CUSTOM="$HOME/.config/kitty/kitty.d"

# Add Java home, IntelliJ to PATH
export JAVA_HOME=/usr/lib/jvm/java
export PATH="$PATH:/opt/idea/bin:/opt/zeal/bin"
alias idea='idea.sh'

# Build-specific modifications
export PATH="$PATH:/opt/gcc-arm-<current_version>-x86_64-arm-none-eabi/bin"
export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/lib" # For pkgconf-based systems

### ...end of file ###

# Exit if not an interactive shell
[ -z "$PS1" ] && return

if [ -f `which powerline-daemon` ]; then
	powerline-daemon -q
	POWERLINE_BASH_CONTINUATION=1
	POWERLINE_BASH_SELECT=1
	. $HOME/.local/lib/python3.11/site-packages/powerline/bindings/bash/powerline.sh
fi

neofetch  --title_fqdn on --distro_shorthand on --refresh_rate on --gtk2 off --gtk3 off --memory_percent on # --gpu_type dedicated
eval "$(gh completion -s bash)"

