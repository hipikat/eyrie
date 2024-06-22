# Ada's Eyrie Repo

Wherein I set up a little space for myself on the web, and learn a bunch of stuff as I go.

## Requirements

```brew install pdm```

## Getting started

- Activate your virtualenv: `pdm venv activate`

## Running test

- `pytest --env=dev`

## Use a development image

- `docker build --target dev -t eyrie-dev:latest .`