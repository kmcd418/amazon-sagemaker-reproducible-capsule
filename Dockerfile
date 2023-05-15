FROM python:3.10-slim

ENV PYTHONUNBUFFERED=TRUE

# install gcc
RUN apt-get update \
    && apt-get install -y gcc git \
    && apt-get clean

# install python dependencies
RUN pip install --no-cache --upgrade \
    sagemaker-training==4.4.5