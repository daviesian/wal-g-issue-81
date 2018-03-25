FROM postgres:10

RUN apt-get update
RUN apt-get install -y curl

RUN curl -L https://github.com/wal-g/wal-g/releases/download/v0.1.7/wal-g.linux-amd64.tar.gz | tar zx -C /usr/local/bin