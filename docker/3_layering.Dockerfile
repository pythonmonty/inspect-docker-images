FROM python:3.12-slim
ARG TOKEN
ARG DEBIAN_FRONTEND=noninteractive

ENV POETRY_VERSION="2.1.0" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=0 \
    POETRY_VIRTUALENVS_IN_PROJECT=0 \
    POETRY_HTTP_BASIC_PYTHONMONTY_USERNAME="docker-user" \
    POETRY_HTTP_BASIC_PYTHONMONTY_PASSWORD="$TOKEN"

RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq5 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install poetry=="$POETRY_VERSION"

WORKDIR /app
COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root

COPY cat_app ./cat_app
CMD ["python", "cat_app/app.py"]
