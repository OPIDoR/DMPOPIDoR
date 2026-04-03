FROM ruby:3.4.9-slim-trixie AS base
WORKDIR /app
RUN apt update -y && apt install -y --no-install-recommends \
  build-essential \
  ca-certificates  \
  curl \
  gnupg \
  libpq-dev \
  libyaml-dev \
  libffi-dev \
  imagemagick \
  libxrender1 \
  libxext6 \
  libffi-dev \
  libfontconfig1 \
  tzdata \
  gnupg2 && \
  apt-get clean && rm -rf /var/lib/apt/lists/* && \
  ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

FROM base AS dev
ARG NODE_MAJOR=24
COPY . .
RUN mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
  apt-get update -y && \
  apt-get install -y --no-install-recommends nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  npm install -g yarn
RUN bundle install --jobs=4 --retry=3
RUN yarn install && \
  yarn cache clean

FROM dev AS production-builder
ARG DB_ADAPTER \
  DB_USERNAME \
  DB_PASSWORD
RUN bin/docker ${DB_ADAPTER:-postgres} && \
  RAILS_ENV=build DISABLE_SPRING=1 NODE_OPTIONS=--openssl-legacy-provider rails assets:precompile && \
  bundle config set --local without 'thin test ci aws development build' && \
  bundle install --jobs=4 --retry=3 && \
  rm -rf /usr/local/bundle/cache

FROM base AS production
COPY . .
RUN groupadd -r dmpopidor && useradd -r -g dmpopidor -d /app -s /bin/bash dmpopidor && \
    chown -R dmpopidor:dmpopidor /app
COPY --chown=dmpopidor:dmpopidor --from=production-builder /app/public ./public
COPY --chown=dmpopidor:dmpopidor --from=production-builder /app/config ./config
COPY --chown=dmpopidor:dmpopidor --from=production-builder /usr/local/bundle /usr/local/bundle
USER dmpopidor
EXPOSE 3000
CMD [ "/app/bin/run" ]
