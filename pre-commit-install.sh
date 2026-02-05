#!/bin/bash
set -e

WORK_DIR="/opt/git-hook/precommit_env"
HOOKS_DIR="$WORK_DIR/git-hooks"
VENV_DIR="$WORK_DIR/venv"

if [ ! -d ".git" ]; then
    echo "Error: .git directory not found. Please run this from the project root."
    exit 1
fi

echo "Starting pre-commit setup..."

mkdir -p "$HOOKS_DIR"
mkdir -p "$VENV_DIR"

if [ ! -f "$VENV_DIR/bin/pre-commit" ]; then
    echo "Creating virtual environment and installing pre-commit..."
    python3 -m venv "$VENV_DIR"
    "$VENV_DIR/bin/pip" install pre-commit
else
    echo "Pre-commit is already installed in venv."
fi

echo "Installing git hook..."
git config --unset core.hooksPath || true
"$VENV_DIR/bin/pre-commit" install

echo "Moving hook to executable partition..."
mv .git/hooks/pre-commit "$HOOKS_DIR/pre-commit"
chmod +x "$HOOKS_DIR/pre-commit"

git config core.hooksPath "$HOOKS_DIR"

if [ "$(git config core.hooksPath)" == "$HOOKS_DIR" ]; then
    echo "Success! Hooks are now configured in: $HOOKS_DIR"
    echo "You can test it with: $VENV_DIR/bin/pre-commit run --all-files"
else
    echo "Error: Failed to set core.hooksPath."
    exit 1
fi
