FROM python:3.13.18-slim-trixie

# Nextflow uses ps to record task metrics
RUN apt-get update \
    && apt-get install -y --no-install-recommends procps \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir biopython==1.88 numpy==2.5.4

RUN useradd --create-home --uid 1000 summary
USER summary
