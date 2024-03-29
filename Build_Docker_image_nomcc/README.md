# Build Docker image for nomcc

Here is a small tip on how to build a Docker image for [nomcc](https://github.com/akamai/nomcc).

**Dockerfile**
```text
FROM docker.io/python:3.11.4-bookworm

WORKDIR /
RUN git clone https://github.com/akamai/nomcc.git

WORKDIR /nomcc
RUN python3 setup.py install

WORKDIR /app

CMD ["python3"]
```

Build the image.
```text
$ docker image build --rm -t local/nomcc .
```

Run the script.
```text
$ docker container run --rm -v $(pwd):/app local/nomcc:latest ./nomcc_script.py
```
