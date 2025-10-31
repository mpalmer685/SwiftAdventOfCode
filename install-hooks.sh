#!/usr/bin/env bash

# All paths should be relative to the main git repository root
# Worktrees still point to the main git hooks directory
root_dir="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
hooks_dir="$root_dir/.githooks"
git_hooks_dir="$root_dir/.git/hooks"
flag_file="$git_hooks_dir/.hooks_installed"

echo "Checking git hooks installation..."

hooks_to_install=()
if [ -f "$flag_file" ]; then
    while IFS='' read -r line; do
        hooks_to_install+=("$line")
    done < <(find "$hooks_dir" -type f -maxdepth 1 -Bnewer "$flag_file" -exec basename {} \;)
else
    while IFS='' read -r line; do
        hooks_to_install+=("$line")
    done < <(find "$hooks_dir" -type f -maxdepth 1 -exec basename {} \;)
fi

# If all hooks are already installed, exit
if [ ${#hooks_to_install[@]} -eq 0 ]; then
    echo "Git hooks are already installed."
    exit 0
fi

if [ ! -d "$hooks_dir" ]; then
    echo "Hooks directory $hooks_dir does not exist."
    exit 1
fi

# Install hooks
for hook in "${hooks_to_install[@]}"; do
    src="$hooks_dir/$hook"
    dest="$git_hooks_dir/$hook"

    echo "Installing hook: $hook"
    ln -sf "$src" "$dest"
    chmod +x "$dest"
done

# Update the flag file
touch "$flag_file"

echo "Git hooks installation complete."
