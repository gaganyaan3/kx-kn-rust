#!/bin/bash

if [ "$1" = '--uninstall' ]; then
    rm -rf $HOME/.local/bin/kx $HOME/.local/bin/kn
    echo "Uninstall kn and kx from $HOME/.local/bin/kn $HOME/.local/bin/kx"
    exit
fi

function installed_msg() {
    echo "Installed kn and kx $tag_name at $HOME/.local/bin/kx $HOME/.local/bin/kn"
    if [ "$(echo "$PATH" | grep -o "$HOME/.local/bin")" != "$HOME/.local/bin" ]; then
        echo ''
        echo '    Please add "$HOME/.local/bin" to your $PATH'
        echo '    PATH="$PATH:$HOME/.local/bin"'
        echo ''
    fi
}

#### check curl
if ! [ -x "$(command -v curl)" ]; then
    echo 'Error: curl is not installed.' >&2
    exit 1
fi

#### check Architecture
if [ "$(uname -m | grep -o aarch64)" = "aarch64" ]; then
    arch=arm64
elif [ "$(uname -m | grep -o arm64)" = "arm64" ]; then
    arch=arm64
elif [ "$(uname -m | grep -o x86_64)" = "x86_64" ]; then
    arch=x86_64
else
    echo "$(uname -m) $(uname) OS not supported by this script :("
fi

if [ "$(uname)" = "Linux" ] && [ "x86_64" = "$arch" ] ; then
    cd /tmp
    tag_name=$(curl -s "https://api.github.com/repos/koolwithk/kx-kn-rust/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -s https://github.com/koolwithk/kx-kn-rust/releases/download/$tag_name/kn-$tag_name-x86_64-linux-musl.tar.gz -L --output kn-$tag_name-x86_64-linux-musl.tar.gz
    tar -xzf kn-$tag_name-x86_64-linux-musl.tar.gz
    rm -rf kn-$tag_name-x86_64-linux-musl.tar.gz
    mkdir -p $HOME/.local/bin
    mv kn $HOME/.local/bin

    curl -s https://github.com/koolwithk/kx-kn-rust/releases/download/$tag_name/kx-$tag_name-x86_64-linux-musl.tar.gz -L --output kx-$tag_name-x86_64-linux-musl.tar.gz
    tar -xzf kx-$tag_name-x86_64-linux-musl.tar.gz
    rm -rf kx-$tag_name-x86_64-linux-musl.tar.gz
    mv kx $HOME/.local/bin
    installed_msg

elif [ "$(uname)" = "Linux" ] && [ "arm64" = "$arch" ] ; then
    cd /tmp
    tag_name=$(curl -s "https://api.github.com/repos/koolwithk/kx-kn-rust/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -s https://github.com/koolwithk/kx-kn-rust/releases/download/$tag_name/kn-$tag_name-arm64-musl-linux.tar.gz -L --output kn-$tag_name-arm64-musl-linux.tar.gz
    tar -xzf kn-$tag_name-arm64-musl-linux.tar.gz
    rm -rf kn-$tag_name-arm64-musl-linux.tar.gz
    mkdir -p $HOME/.local/bin
    mv kn $HOME/.local/bin

    curl -s https://github.com/koolwithk/kx-kn-rust/releases/download/$tag_name/kx-$tag_name-arm64-musl-linux.tar.gz -L --output kx-$tag_name-arm64-musl-linux.tar.gz
    tar -xzf kx-$tag_name-arm64-musl-linux.tar.gz
    rm -rf kx-$tag_name-arm64-musl-linux.tar.gz
    mv kx $HOME/.local/bin
    installed_msg
else
    echo "$(uname -m) $(uname) OS not supported by this script :("
fi