#
# Image targets for eyrie containers:
# - base-prod: Python/Alpine image
# - base-dev: Ubuntu/Noble with minimal system packages
#

# Base image for production-like containers
FROM python:3.12.4-alpine3.20 as base-prod
ENV LANG en_AU.UTF-8
SHELL ["/bin/sh", "-c"]


# Minimal 'unminimised' Ubuntu image
FROM ubuntu:noble-20240605 AS base-ubuntu

ARG admin_user=roc
ARG admin_shell=/bin/zsh

ENV LANG en_AU.UTF-8
ENV LANGUAGE en_AU:en
ENV LC_ALL en_AU.UTF-8
ENV MANPAGER less

RUN yes | unminimize
RUN apt-get install -y locales && locale-gen en_AU.UTF-8
RUN apt-get install -y less man-db

# Base image for development and debug containers
FROM base-ubuntu AS base-dev
SHELL ["/bin/bash", "-c"]

# Add 'roc' as the default non-root application admin user
RUN useradd -ms $admin_shell $admin_user

RUN apt-get install -y --no-install-recommends\
    python3.12 pipx git just screen sudo zsh

WORKDIR /app


# Minimal development image
FROM base-dev AS dev
LABEL description="Base image for eyrie containers"

ARG http_port=8060

ENV EYRIE_DEBUG=true
ENV DJANGO_SETTINGS_MODULE=eyrie.web.settings.dev

RUN apt-get install -y --no-install-recommends \
    pipx git
RUN pipx install pdm

COPY scripts/ /app/scripts/
COPY config/ /app/config/
COPY tests/ /app/tests/
COPY src/ /app/src/
COPY conftest.py LICENSE.txt pdm.lock pyproject.toml pytest.ini README.md /app/

# # Install dependencies using pdm
# RUN . /opt/venv/bin/activate \
#     && pdm install \
#     > /install-log.txt 2>&1 \
#     && cat /install-log.txt

# Command to run tests (will be overwritten when running container)
EXPOSE 8060/tcp
ENTRYPOINT ["src/docker-entrypoint.sh"]
# CMD ["python", "-m", "http.server", ]
CMD python3 -m http.server 8060
