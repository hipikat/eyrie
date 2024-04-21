
include:
  - salt_formula
  - users

salt:
  minion:
    file_roots:
      base:
        - /srv/salt
        - /srv/formulas/salt-formula


salt_formulas:
  list:
    development:
      - salt-formula