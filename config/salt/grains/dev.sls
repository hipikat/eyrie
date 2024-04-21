# # /srv/pillar/development.sls
# include:
#   - base

# development_config:
#   db_engine: postgresql
#   debug: true

# environment: 'dev'

docker:
  wanted:
    - docker
    - compose