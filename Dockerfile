FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y asterisk

RUN apt -y install python3 python3-venv pip
RUN python3 -m venv asterisk-scripts-venv
RUN /asterisk-scripts-venv/bin/pip install paho-mqtt

