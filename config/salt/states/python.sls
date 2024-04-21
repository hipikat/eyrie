
deadsnakes-ppa:
  pkgrepo.managed:
    - name: ppa:deadsnakes/ppa
    - file: /etc/apt/sources.list.d/deadsnakes.list
    - key_url: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9D8D3B2F
    - refresh_db: true

python3.12:
  pkg.installed:
    - name: python3.12
    - require:
      - pkgrepo: deadsnakes-ppa

pip_installed:
  pkg.installed:
    - name: python3-pip
    - require:
      - pkg: python3.12

pipx_installed:
  pkg.installed:
    - name: pipx
    - require:
      - pkg: python3.12

poetry_installed:
  cmd.run:
    - name: pipx install poetry
    - unless: pipx list | grep -q poetry
    - require:
      - pkg: pipx

hatch_installed:
  pip.installed:
    - name: hatch
    - bin_env: /usr/bin/pip
    - require:
      - pkg: python3.12