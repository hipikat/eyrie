#!/usr/bin/env bash
# Enable Bash Strict Mode
set -eo pipefail
IFS=$'\n\t'

echo "Entering docker-entrypoint.sh"

activate_virtualenv() {
  if [ -d "/app/.venv" ]; then
    echo "Activating virtual environment at /app/.venv"
    source /app/.venv/bin/activate
  else
    echo "Virtual environment at /app/.venv not found. Skipping activation."
  fi
}

# Create a user with the same UID/GID as the host user
if [ -n "$HOST_UID" ] && [ -n "$HOST_GID" ] && [ -n "$HOST_USERNAME" ]; then
  echo "Ensuring user '$HOST_USERNAME' exists, with UID: $HOST_UID, GID: $HOST_GID"

  # Create the group if it doesn't exist
  if ! getent group "$HOST_GID" >/dev/null; then
    groupadd -g "$HOST_GID" "$HOST_USERNAME"
  fi

  # Create the user if it doesn't exist
  if ! id -u "$HOST_UID" >/dev/null 2>&1; then
    useradd -u "$HOST_UID" -g "$HOST_GID" -m "$HOST_USERNAME"
  fi

  # Change ownership of the /app directory to the new user
  # chown -R "$HOST_UID":"$HOST_GID" /app

  # Switch to the new user
  sudo -u "$HOST_USERNAME" bash
fi

# Setup environment
pipx ensurepath --quiet
activate_virtualenv

echo "Running as $(whoami) with environment:"
env

if [ $# -eq 0 ]; then
  echo "Going to bash…"
  exec /bin/bash
else
  echo "Executing: $@"
  exec "$@"
fi
