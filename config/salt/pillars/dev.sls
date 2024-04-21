#
# Salt states for the 'development' environment
#

include:
  - base
  - docker

salt:
  minion:
    file_roots:
      development:
        - /srv/salt
        - /srv/formulas/salt-formula

    # Use Salt in a standalone, masterless mode.
    master_type: disable

salt_formulas:
  list:
    development:
      - salt-formula
      - users-formula
      - docker-formula
      - nginx-formula


