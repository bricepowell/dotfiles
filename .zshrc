export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="bira"

export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
plugins=(
    git
    zsh-npm-scripts-autocomplete
    zsh-nvm
    jira
)

source $ZSH/oh-my-zsh.sh
eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/catppuccin_mocha.omp.json)"
source ~/.zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Assumes that the following packages have been installed
# - Homebrew: https://brew.sh/
# - NVM: https://github.com/nvm-sh/nvm
# - PYENV: https://formulae.brew.sh/formula/pyenv
# - RBENV: https://formulae.brew.sh/formula/rbenv
# - Java JDK: https://adoptium.net/temurin/releases/?os=mac&package=jdk&version=17
# - Gradle 7: https://formulae.brew.sh/formula/gradle@7
# - Android Studio 2022.2.1 Patch 2: https://developer.android.com/studio/archive

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

HOMEBREW_ROOT=/usr/local

# Checks for M1 arch
if [[ $(uname -m) == 'arm64' ]]; then
  HOMEBREW_ROOT=/opt/homebrew
fi

eval $($HOMEBREW_ROOT/bin/brew shellenv)

export RBENV_SHELL=zsh
export GRADLE_HOME=$HOMEBREW_ROOT/opt/gradle@7
export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export NODE_OPTIONS=--max-old-space-size=8192

export PATH=$PATH:$HOME/.pyenv/shims
export PATH=$PATH:$HOME/.rbenv/shims
export PATH=$PATH:$HOME/dev/HRSDocker/scripts/bin/
export PATH=$PATH:$GRADLE_HOME/bin
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
export JAVA_OPTS="-Xmx4096m"
export GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx4096m"
rbenv global 3.2.0
pyenv global 2.7.18

alias cb='docker run --privileged=true --rm -it -v \`pwd\`:/code -w /code -v $HOME/.m2:/root/.m2  healthrecoverysolutions/ci-base'
alias glgraph="git log --oneline --graph --decorate --all --date=short --pretty=format:'%Cblue%cd %C(yellow)%h %C(cyan)[%an]%Creset -%C(auto)%d%Creset %s %Creset'"

# Auto-load node version when opening a new terminal in a project context
if test -f .nvmrc; then
  nvm use
fi

# AWS Env Variables --------------------------------------------------------------------------------------------------------------------------
export AWS_ACCESS_KEY_ID=`cat ~/.aws/credentials | grep -i aws_access_key_id | cut -d "=" -f2- | sed -e 's/^[[:space:]]*//'`
export AWS_SECRET_ACCESS_KEY=`cat ~/.aws/credentials | grep -i aws_secret_access_key | cut -d "=" -f2- | sed -e 's/^[[:space:]]*//'`
export AWS_DEFAULT_REGION="us-east-1"

# AWS SSM interactive functions --------------------------------------------------------------------------------------------------------------------------
aws-login() {
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 072805691757.dkr.ecr.us-east-1.amazonaws.com
}

session-list() {
    docker run -t -i -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION --rm 072805691757.dkr.ecr.us-east-1.amazonaws.com/session-manager:latest searchssm
}

session-search() {
    docker run -t -i -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION --rm 072805691757.dkr.ecr.us-east-1.amazonaws.com/session-manager:latest searchssm "$@"
}

session-start() {
    docker run -t -i -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION --rm 072805691757.dkr.ecr.us-east-1.amazonaws.com/session-manager:latest aws ssm start-session --target "$@" --document-name AWS-StartInteractiveCommand --parameters command="cd ~ && bash -l"
}

# Aliases --------------------------------------------------------------------------------------------------------------------------
alias cb="docker run --rm -it -v \$(pwd):/code -w /code -v \$HOME/.m2:/root/.m2 healthrecoverysolutions/ci-base"
alias uibuild="sh scripts/build.sh"
alias uipack="sh scripts/pack.sh"
alias uipatch="sh scripts/patch.sh"
alias uipub="sh scripts/publish.sh"
alias uistart="sh scripts/start.sh"
alias uipcm="uipack && mv packs/*.tgz ../../HRSMobileBYOD/apps/mobile-patient/ && cd ../../HRSMobileBYOD/apps/mobile-patient/ && npm i hrsui-angular-*.tgz hrsui-core-*.tgz"
alias lzd='lazydocker'
alias ls="exa --icons --git"
alias disableWifi="adb shell svc wifi disable"
alias enableWifi="adb shell svc wifi enable"
alias stopPCM="adb shell am force-stop com.hrs.patient"
alias startPCM="adb shell am start -n com.hrs.patient/com.hrs.patient.MainActivity"
alias restartPCM="stopPCM && startPCM"
alias uninstallPCM="adb uninstall com.hrs.patient"
alias installPCM="adb install platforms/android/app/build/outputs/apk/debug/app-debug.apk"
eval "$(zoxide init zsh)"
