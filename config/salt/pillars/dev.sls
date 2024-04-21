#
# Salt states for the 'development' environment
#

include:
  - base

salt:
  minion:
    master_type: disable
    file_roots:
      development:
        - /srv/salt
        - /srv/formulas/salt-formula

salt_formulas:
  list:
    development:
      - salt-formula
      - users-formula
      - nginx-formula