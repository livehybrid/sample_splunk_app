FROM python:3.8.3-slim-buster

RUN apt-get update && \
    apt-get install -yq make gcc build-essential libmagic-dev  && \
    apt-get clean && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir poetry