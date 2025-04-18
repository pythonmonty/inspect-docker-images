FROM python:3.12-slim
ARG TOKEN
ARG DEBIAN_FRONTEND=noninteractive

ENV POETRY_VERSION="2.1.0" \
    POETRY_HOME=/opt/poetry \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache \
    POETRY_HTTP_BASIC_PYTHONMONTY_USERNAME="docker-user" \
    POETRY_HTTP_BASIC_PYTHONMONTY_PASSWORD="$TOKEN" \
    PATH="/app/.venv/bin:$PATH"

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5=15.12-0+deb12u2 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m venv $POETRY_HOME \
    && $POETRY_HOME/bin/pip install --no-cache-dir poetry=="$POETRY_VERSION"

WORKDIR /app
COPY pyproject.toml poetry.lock ./

RUN $POETRY_HOME/bin/poetry install --no-root --only main \
    && rm -rf $POETRY_CACHE_DIR

COPY cat_app ./cat_app
CMD ["python", "cat_app/app.py"]
