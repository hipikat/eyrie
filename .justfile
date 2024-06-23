#!/usr/bin/env just --justfile

set dotenv-load
set positional-arguments

# Constants/Preferences
default_shell := 'bash'

# Get the project name from 'name' in '[project]' in 'pyproject.toml'
project_name := `awk '/^\[project\]/ { proj = 1 } proj && /^name = / { gsub(/"/, "", $3); print $3; exit }' pyproject.toml`
shell_prefix := '\U1F41A \n'

# Print system info and available `just` recipes
_default:
  @echo "This is an {{arch()}} machine with {{num_cpus()}} cpu(s), running {{os()}}."
  @echo "Running: {{just_executable()}}"
  @echo "   with: {{justfile()}}"
  @echo "    cwd: {{invocation_directory_native()}}"
  @echo ""
  @just --list

# DOCKER - clean up, build latest, run containers & services

# Remove exited containers named '{{project_name}}-{{env}}'
[group('docker')]
docker-clean stage='dev':
  docker ps -qa -f "status=exited" -f "name={{project_name}}-{{stage}}" | xargs -r docker rm

# Build the 'latest' docker image from a stage in Dockerfile
[group('docker')]
docker-build stage='dev' *flags='':
  docker build {{flags}} -t {{project_name}}-{{stage}}:latest --target {{stage}} .

# Run a temporary, interactive container from Dockerfile's 'stage'
[group('docker')]
docker-run stage='dev' *args='': (docker-build stage)
  docker run --rm -it {{project_name}}-{{stage}} {{args}}

# Bring up a service defined in docker-compose.yml
[group('docker')]
docker-compose-up service='dev' *flags='':
  docker compose -p {{project_name}} up {{flags}} {{service}}

# Take down a service defined in docker-compose.yml
[group('docker')]
docker-compose-down service='dev' *flags='':
  docker compose -p {{project_name}} down {{flags}} {{service}}

# Execute 'cmd' aganst a service defined in docker-compose.yml
[group('docker')]
docker-compose-exec service='dev' *cmd='':
  docker compose -p {{project_name}} exec {{service}} {{cmd}}


# WORKFLOW - clean, build, run… stuff

# Clean
[group('workflow')]
clean target='':
  just docker-clean {{target}}

# Build
[group('workflow')]
build target='':
  just docker-build {{target}}

# Run 'cmd' in a service specified by docker-compose.yml
[group('workflow')]
develop env='dev' cmd='bash': (docker-compose-up env '-d')
  just docker-compose-exec {{env}} {{cmd}}