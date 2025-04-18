FROM python:3.12
ARG TOKEN

ENV DEBIAN_FRONTEND=noninteractive
ENV POETRY_VERSION="2.1.0"
ENV POETRY_NO_INTERACTION=1
ENV POETRY_VIRTUALENVS_CREATE=0
ENV POETRY_VIRTUALENVS_IN_PROJECT=0

ENV POETRY_HTTP_BASIC_PYTHONMONTY_USERNAME="docker-user"
ENV POETRY_HTTP_BASIC_PYTHONMONTY_PASSWORD="$TOKEN"
RUN echo "$POETRY_HTTP_BASIC_FOO_PASSWORD"

RUN apt-get update
RUN apt-get install -y --no-install-recommends software-properties-common \
    imagemagick \
    build-essential \
    python3-distutils \
    python3-venv \
    python3-pip \
    python3-wheel \
    python3-dev \
    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3

RUN apt-get update
RUN apt-get install --no-install-recommends -y libsm6 \
    libxext6 \
    libxrender-dev \
    libglib2.0-0 \
    libgl1

WORKDIR /app
COPY . .

RUN pip install poetry=="$POETRY_VERSION"
RUN poetry install

CMD ["python", "cat_app/app.py"]
