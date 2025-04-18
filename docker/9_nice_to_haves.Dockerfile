ARG INSTALLER_VENV_PATH=/build/.venv

FROM python:3.12-slim@sha256:85824326bc4ae27a1abb5bc0dd9e08847aa5fe73d8afb593b1b45b7cb4180f57 as base
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

FROM base as installer
ARG INSTALLER_VENV_PATH

ENV POETRY_VERSION="2.1.0" \
    POETRY_HOME=/opt/poetry \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    PATH="${INSTALLER_VENV_PATH}/bin:$PATH"

RUN python -m venv $POETRY_HOME \
    && $POETRY_HOME/bin/pip install poetry=="$POETRY_VERSION"

WORKDIR /build

RUN --mount=type=secret,id=user,target=/root/artifacts/user \
    --mount=type=secret,id=token,target=/root/artifacts/token \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=poetry.lock,target=poetry.lock \
    sh -c 'POETRY_HTTP_BASIC_PYTHONMONTY_USERNAME=$(cat /root/artifacts/user) \
           POETRY_HTTP_BASIC_PYTHONMONTY_PASSWORD=$(cat /root/artifacts/token) \
           $POETRY_HOME/bin/poetry install --no-root --only main && \
           rm -rf $POETRY_CACHE_DIR'

FROM base as runner
ARG INSTALLER_VENV_PATH
ARG WORKDIR=/app

ENV PATH="${WORKDIR}/.venv/bin:$PATH" \
    DOCKER_USER=appuser \
    DOCKER_GROUP=appuser \
    UID=1001 \
    GID=1001

LABEL org.opencontainers.image.title="The Cat App" \
      org.opencontainers.image.description="A Flask app that sends requests to The Cat API." \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.authors="Irena Grgic <irena.grgic11@gmail.com>" \
      org.opencontainers.image.source="https://github.com/pythonmonty/inspect-docker-images"


RUN groupadd -g "$GID" "$DOCKER_GROUP" && \
    useradd -l -u "$UID" -g "$DOCKER_GROUP" -s /bin/sh -m "$DOCKER_USER"

COPY --from=installer $INSTALLER_VENV_PATH $WORKDIR/.venv

WORKDIR $WORKDIR
COPY cat_app ./cat_app

USER "$DOCKER_USER"
EXPOSE 3000
CMD ["python", "cat_app/app.py"]
