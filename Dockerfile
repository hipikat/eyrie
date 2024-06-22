# Base image for development & debug containers
FROM ubuntu:noble-20240605 AS base-dev
ENV LANG en_AU.UTF-8
SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
    git
    # && rm -rf /var/lib/apt/lists/*

WORKDIR /app/


# Base image for production-like containers
FROM python:3.12.4-alpine3.20 as base-prod
ENV LANG en_AU.UTF-8
SHELL ["/bin/sh", "-c"]
WORKDIR /app/


# Minimal development image
FROM base-dev AS dev
LABEL description="Base image for eyrie containers"
ENV EYRIE_DEBUG=true
ENV DJANGO_SETTINGS_MODULE=eyrie.web.settings.dev

COPY / /app/

# # Install pipx and pdm using a virtual environment
# RUN python3 -m venv /opt/venv \
#     && . /opt/venv/bin/activate \
#     && pip install --upgrade pip \
#     && pip install pipx \
#     && pipx ensurepath \
#     && pipx install pdm \
#     > /install-log.txt 2>&1 \
#     && cat /install-log.txt

# # Copy pyproject.toml to the image
# COPY pyproject.toml /app/

# # Install dependencies using pdm
# RUN . /opt/venv/bin/activate \
#     && pdm install \
#     > /install-log.txt 2>&1 \
#     && cat /install-log.txt

# Command to run tests (will be overwritten when running container)
EXPOSE 8060/tcp
CMD ["bash"]
