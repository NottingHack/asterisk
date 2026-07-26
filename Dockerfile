FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y asterisk python3 python3-venv pip curl jq && \
    python3 -m venv asterisk-scripts-venv && \
    /asterisk-scripts-venv/bin/pip install paho-mqtt

