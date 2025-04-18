ARG INSTALLER_VENV_PATH=/build/.venv

FROM python:3.12-slim as base
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
COPY pyproject.toml poetry.lock ./

RUN --mount=type=secret,id=user,target=/root/artifacts/user \
    --mount=type=secret,id=token,target=/root/artifacts/token \
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

RUN groupadd -g "$GID" "$DOCKER_GROUP" && \
    useradd -u "$UID" -g "$DOCKER_GROUP" -s /bin/sh -m "$DOCKER_USER"

COPY --from=installer $INSTALLER_VENV_PATH $WORKDIR/.venv

WORKDIR $WORKDIR
COPY cat_app ./cat_app

USER "$DOCKER_USER"
CMD ["python", "cat_app/app.py"]

