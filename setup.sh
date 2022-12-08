#!/usr/bin/env bash
#
cd "$(dirname "${BASH_SOURCE[0]}")"
set -ex -o pipefail

cp .config/nvim/init.lua ~/.config/nvim/.
cp .tmux.conf ~/.tmux.conf
