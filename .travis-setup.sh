#!/bin/sh

set -eux

get_retry() {
  cmd=$*
  $cmd || (sleep 10 && $cmd) || (sleep 10 && $cmd)
}

get_stack_osx() {
  curl -skL https://www.stackage.org/stack/osx-x86_64 | tar xz --strip-components=1 --include '*/stack' -C ~/.local/bin;
}

get_stack_linux() {
  curl -sL https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack';
}

case "$BUILD" in
  stack)
    mkdir -p ~/.local/bin;
    if [ `uname` = "Darwin" ]; then
      get_retry get_stack_osx
    else
      get_retry get_stack_linux
    fi;

    get_retry stack --no-terminal setup;
    ;;
  cabal)
mkdir -p $HOME/.cabal
cat > $HOME/.cabal/config <<EOF
remote-repo: hackage.haskell.org:http://hackage.fpcomplete.com/
remote-repo-cache: $HOME/.cabal/packages
jobs: \$ncpus
EOF
;;
esac

