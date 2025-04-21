# Size matters: Inspecting Docker images for Efficiency and Security

This repository goes hand-in-hand with this [Pycon 2025 conference talk](https://2025.pycon.de/talks/GJ9MVT/).

The repository structure is as follows:

- [.github/workflows](.github/workflows): contains GitHub Actions pipelines (e.g. [Trivy](https://trivy.dev/latest/)
  scan).
- [cat_app/](cat_app): contains the Python module with a simple Flask app.
- [docker](docker): contains examples of Dockerfiles.
- [slides/](slides): contain the conference talk slides.
- [tests](tests): Pytests for the Flaks app.
- [pyproject.toml](pyproject.toml): contains Python dependencies that [Poetry](https://python-poetry.org)
  should install.
- [poetry.lock](poetry.lock): Poetry lock file where all package dependencies are locked and hashed.

## Conference talk abstract

Inspecting Docker images is crucial for building secure and efficient containers. In this session, we will analyze
the structure of a Python-based Docker image using various tools, focusing on best practices for minimizing image size
and reducing layers with multi-stage builds. We’ll also address common security pitfalls, including proper handling of
build and runtime secrets.

While this talk offers valuable insights for anyone working with Docker, it is especially beneficial for Python
developers seeking to master clean and secure containerization techniques.

### Outline

1. **Introduction**
    - We start with an example Dockerfile for a Python-based image.
    - We will explore the role of OverlayFS, Docker’s file system for combining layers, to understand how layers stack
      and how data (or even secrets) can be retrieved from individual layers.

2. **Layer Analysis**
    - To gain better understanding of layering, we use simple command-line tools like `docker history` and
      `docker inspect` to examine image layers.
    - We introduce `dive`, a tool for exploring the contents of each layer.
    - We apply these insights to optimize the image by implementing multi-stage builds to create a smaller image with
      fewer layers, improving storage efficiency, build speed, and security.
    - We discuss the benefits of Docker’s caching mechanism in reducing build times.

3. **Security Enhancements**
    - Given our example image, we will use `trivy`, a comprehensive security scanner, to scan the example image for
      vulnerabilities and demonstrate how to address common issues.
    - Finally, we introduce `hadolint`, an open-source linter for Dockerfiles.

## Prerequisites

To be able to build the Docker images in this repository, you will need to have the following prerequisite
fulfilled.

### 1. Docker Engine must be running on your machine

You can download and install [Docker Desktop](https://docs.docker.com/get-started/get-docker/) for Linux, Mac or
Windows. Docker Desktop is free for non-commercial use. Alternatively, if running on Linux, you can install
[Docker CE](https://docs.docker.com/engine/install/).

### 2. Access to the private package `random-cat-generator`

Examples in this repository install a package
[`random-cat-generator`](https://dev.azure.com/pythonmonty/Demo/_artifacts/feed/random-cat-generator/PyPI/random-cat-generator/overview/0.1.1)
from a private Azure DevOps Artifacts feed. The purpose is to simulate common industry scenarios, where authentication
to private package registries is needed for the installation. In order to build images from the [docker/](docker)
directory, you will need to:

- be added to the corresponding private Azure DevOps project,
- create an Azure DevOps Personal Access Token (PAT) with read access to Artifacts,
- pass the PAT when building the images, as explained during the talk.

## Installation

The directory [cat_app](cat_app) contains an example Python Flask app which sends requests to
[The Cat API](https://thecatapi.com/) and displays an image of a cat on a simple web page. To be able to run the Docker
build examples from the talk, you don't have to have a Python or a Poetry installation on your machine.
Both are only needed for the development of the Flask app.

All Dockerfiles can be found in the [docker](docker) directory.

> :memo: **Note:** The Docker build examples below include the `--platform linux/amd64` flag since they were ran on
> ARM64 architecture, but need to be AMD64-compatible. If you are running on Linux or want the images to be
> only ARM64-compatible, you can omit the flag.

1. Clone the repository:

   ```bash
   git clone https://github.com/pythonmonty/clean-code-in-python.git
   ```

2. Build the initial image [0_original.Dockerfile](docker/0_original.Dockerfile):

   ```bash
   docker build --platform linux/amd64 --build-arg TOKEN="$PAT" -f docker/0_original.Dockerfile -t 0-original .
   ```

   > :memo: **Note:** Remember to set the PAT as explained in the [Prerequisites](#prerequisites) section before running
   > the above command.
