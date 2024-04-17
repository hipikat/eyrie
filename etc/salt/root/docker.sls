install_docker_dependencies:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates
      - curl
      - gnupg
      - lsb-release

add_docker_gpg_key:
  cmd.run:
    - name: curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    - unless: test -f /usr/share/keyrings/docker-archive-keyring.gpg

add_docker_repository:
  cmd.run:
    - name: |
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    - unless: test -f /etc/apt/sources.list.d/docker.list

update_package_index:
  cmd.run:
    - name: apt-get update
    - require:
      - cmd: add_docker_repository

install_docker:
  pkg.installed:
    - names:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    - require:
      - cmd: update_package_index
