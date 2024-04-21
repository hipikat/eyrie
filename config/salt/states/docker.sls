
docker_required_packages_installed:
  pkg.installed:
    - names:
      - ca-certificates
      - curl

# Add Docker's official GPG key if not already present
docker_gpg_key_installed:
  cmd.run:
    - name: |
        sudo test -f /etc/apt/keyrings/docker.asc || \
        (sudo install -m 0755 -d /etc/apt/keyrings && \
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
        sudo chmod a+r /etc/apt/keyrings/docker.asc)
    - unless: test -f /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources
docker_repo_added:
  cmd.run:
    - name: |
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    - unless: grep -q "docker" /etc/apt/sources.list.d/docker.list
    - require:
      - cmd: docker_gpg_key_installed

# Update apt repositories if Docker isn't installed
docker_apt_updated:
  cmd.run:
    - name: sudo apt-get update
    - unless: dpkg-query -l docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    - require:
      - cmd: docker_repo_added

# Install Docker packages
docker_installed:
  pkg.installed:
    - names:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin