FROM python:3.12-slim@sha256:85824326bc4ae27a1abb5bc0dd9e08847aa5fe73d8afb593b1b45b7cb4180f57
ARG DEBIAN_FRONTEND=noninteractive

ENV POETRY_VERSION="2.1.0" \
    POETRY_HOME=/opt/poetry \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    PATH="/app/.venv/bin:$PATH" \
    DOCKER_USER=appuser \
    DOCKER_GROUP=appuser \
    UID=1001 \
    GID=1001

RUN groupadd -g "$GID" "$DOCKER_GROUP" && \
    useradd -l -u "$UID" -g "$DOCKER_GROUP" -s /bin/sh -m "$DOCKER_USER"

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5=15.12-0+deb12u2 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv $POETRY_HOME \
    && $POETRY_HOME/bin/pip install --no-cache-dir poetry=="$POETRY_VERSION"

WORKDIR /app

RUN --mount=type=secret,id=user,target=/root/artifacts/user \
    --mount=type=secret,id=token,target=/root/artifacts/token \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    --mount=type=bind,source=poetry.lock,target=poetry.lock \
    sh -c 'POETRY_HTTP_BASIC_PYTHONMONTY_USERNAME=$(cat /root/artifacts/user) \
           POETRY_HTTP_BASIC_PYTHONMONTY_PASSWORD=$(cat /root/artifacts/token) \
           $POETRY_HOME/bin/poetry install --no-root --only main && \
           rm -rf $POETRY_CACHE_DIR'

COPY cat_app ./cat_app

USER "$DOCKER_USER"
CMD ["python", "cat_app/app.py"]
