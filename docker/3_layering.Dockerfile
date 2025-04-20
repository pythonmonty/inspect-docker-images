FROM python:3.12-slim@sha256:85824326bc4ae27a1abb5bc0dd9e08847aa5fe73d8afb593b1b45b7cb4180f57
ARG TOKEN
ARG DEBIAN_FRONTEND=noninteractive

ENV POETRY_VERSION="2.1.0" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=0 \
    POETRY_VIRTUALENVS_IN_PROJECT=0 \
    POETRY_HTTP_BASIC_PYTHONMONTY_USERNAME="docker-user" \
    POETRY_HTTP_BASIC_PYTHONMONTY_PASSWORD="$TOKEN"

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5=15.12-0+deb12u2 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install poetry=="$POETRY_VERSION"

WORKDIR /app
COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root

COPY cat_app ./cat_app
CMD ["python", "cat_app/app.py"]
