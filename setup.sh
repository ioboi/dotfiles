#!/usr/bin/env bash
cd "$(dirname "${BASH_SOURCE[0]}")"
set -ex -o pipefail

if [ -L ~/.config/nvim ]; then
	unlink ~/.config/nvim
fi

ln -s $(pwd)/nvim/.config/nvim ~/.config/nvim

if [ -L ~/.tmux.conf ]; then
	unlink ~/.tmux.conf
fi
ln -s $(pwd)/tmux/.tmux.conf ~/.tmux.conf
