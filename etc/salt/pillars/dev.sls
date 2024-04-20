include:
  - docker

salt:
  minion:
    # Use Salt in a standalone, masterless mode.
    master_type: disable
    file_roots:
      development:
        - /srv/salt
        - /srv/formulas/salt-formula

salt_formulas:
  list:
    development:
      - salt-formula
      - openssh-formula
      - docker-formula
      - users-formula


