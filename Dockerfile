FROM ruby:4.0.6-slim-trixie AS base
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates=20250419 \
  libpq5=17.10-0+deb13u1 \
  libxrender1=1:0.9.12-1 \
  imagemagick=8:7.1.1.43+dfsg1-1+deb13u11 \
  && rm -rf /var/lib/apt/lists/*

FROM base AS dev
ENV RAILS_ENV=development
ARG NODE_MAJOR=24
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential=12.12 \
  curl=8.14.1-2+deb13u4 \
  gnupg=2.4.7-21+deb13u1 \
  libffi-dev=3.4.8-2 \
  libpq-dev=17.10-0+deb13u1 \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
    | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
    > /etc/apt/sources.list.d/nodesource.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends nodejs \
  && npm install -g yarn@1.22.22 \
  && rm -rf /var/lib/apt/lists/*
COPY . .
RUN bundle install --jobs=4 --retry=3 \
  && yarn install --frozen-lockfile \
  && yarn cache clean

FROM dev AS production-builder
ARG DB_ADAPTER \
  DB_USERNAME \
  DB_PASSWORD
RUN bin/docker ${DB_ADAPTER:-postgres} && \
  RAILS_ENV=build DISABLE_SPRING=1 NODE_OPTIONS=--openssl-legacy-provider rails assets:precompile \
  && bundle config set --local without 'thin test ci aws development build' \
  && bundle install --jobs=4 --retry=3 \
  && bundle clean --force

FROM base AS production
ENV RAILS_ENV=production
RUN groupadd -r dmpopidor && useradd -r -g dmpopidor -d /app -s /bin/bash dmpopidor \
  &&  chown -R dmpopidor:dmpopidor /app
COPY --from=production-builder --chown=dmpopidor:dmpopidor /usr/local/bundle /usr/local/bundle
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/app ./app
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/bin ./bin
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/cable ./cable
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/config ./config
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/db ./db
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/lib ./lib
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/public ./public
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/swagger ./swagger
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/config.ru ./config.ru
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/entrypoint.sh ./entrypoint.sh
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/Gemfile ./Gemfile
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/Gemfile.lock ./Gemfile.lock
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/package.json ./package.json
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/Procfile ./Procfile
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/Rakefile ./Rakefile
COPY --from=production-builder --chown=dmpopidor:dmpopidor /app/yarn.lock ./yarn.lock
USER dmpopidor
EXPOSE 3000
CMD [ "/app/bin/run" ]
