
salt:
  # master:
  #   formulas:
  #     auto_setup: true
  #     git_opts: "--branch master"
  #     formulas:
  #       nginx:
  #         git: https://github.com/saltstack-formulas/nginx-formula.git
  #       postgres:
  #         git: https://github.com/saltstack-formulas/postgres-formula.git
  clean_config_d_dir: false

salt_formulas:
  git_opts:

    default:
      # baseurl: https://github.com/saltstack-formulas
      baseurl: git@github.com:hipikat
      basedir: /srv/formulas
      update: false
      options:
        rev: main
        # user: root     # TODO: make dynamic
        identity: /etc/salt/keys/eyrie-github-ro    # TODO: make generatable
        # identity: /etc/salt/id_rsa-github-ro
        # identity: /path/to/.ssh/id_rsa_github_username

    development:
      update: true
      options:
        rev: master

  # Options of the file.directory state that creates the directory where
  # the git repositories of the formulas are stored
  basedir_opts:
    makedirs: true
    user: root
    group: root
    mode: 755

    # upstream:
    #   baseurl: git@github.com:saltstack-formulas

  # list:
  #   base:
  #     -