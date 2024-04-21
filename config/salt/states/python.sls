# python.sls

# Ensure the "deadsnakes" PPA is installed
deadsnakes-ppa:
  pkgrepo.managed:
    - name: ppa:deadsnakes/ppa
    - file: /etc/apt/sources.list.d/deadsnakes.list
    - key_url: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9D8D3B2F
    - refresh_db: true

# Install Python 3.12
python3.12:
  pkg.installed:
    - name: python3.12
    - require:
      - pkgrepo: deadsnakes-ppa

poetry_installed:
  pip.installed:
    - name: poetry
    - bin_env: /usr/bin/pip
    - require:
      - pkg: python3.12

hatch_installed:
  pip.installed:
    - name: hatch
    - bin_env: /usr/bin/pip
    - require:
      - pkg: python3.12