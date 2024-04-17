salt:
  master:
    formulas:
      auto_setup: true
      git_opts: "--branch master"
      formulas:
        nginx:
          git: https://github.com/saltstack-formulas/nginx-formula.git
        postgres:
          git: https://github.com/saltstack-formulas/postgres-formula.git
