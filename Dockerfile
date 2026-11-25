FROM haskell:9.8-slim

RUN sed -i '/bullseye-security/d' /etc/apt/sources.list \
    && apt-get update && apt-get install -y --allow-downgrades \
    libssl1.1=1.1.1w-0+deb11u1 \
    default-libmysqlclient-dev \
    libpcre3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY func1.cabal .
RUN cabal update && cabal build --only-dependencies

COPY app ./app
RUN cabal build

CMD ["cabal", "run", "func1", "-v0"]