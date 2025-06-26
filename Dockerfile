FROM ruby:3.4.4-slim AS base
WORKDIR /app
RUN apt update -y && apt install -y --no-install-recommends \
  build-essential \
  ca-certificates  \
  curl \
  gnupg \
  libpq-dev \
  libyaml-dev \
  wkhtmltopdf \
  imagemagick \
  tzdata \
  gnupg2 && \
  apt-get clean && rm -rf /var/lib/apt/lists/*
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarnkey.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/yarnkey.gpg] https://dl.yarnpkg.com/debian/ stable main" > \
  /etc/apt/sources.list.d/yarn.list && \
  apt-get update -y && apt-get install -y --no-install-recommends yarn && \
  apt-get clean && rm -rf /var/lib/apt/lists/*
RUN ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
  ln -sf /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf && \
  chmod +x /usr/local/bin/wkhtmltopdf

FROM base AS dev
ARG NODE_MAJOR=22
COPY . .
RUN mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
  apt-get update -y && \
  apt-get install -y --no-install-recommends nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*
RUN bundle install --jobs=4 --retry=3
RUN yarn install && \
  yarn --cwd app/javascript/dmp_opidor_react install && \
  yarn cache clean

FROM dev AS production-builder
ARG DB_ADAPTER \
  DB_USERNAME \
  DB_PASSWORD
RUN bin/docker ${DB_ADAPTER:-postgres} && \
  RAILS_ENV=build DISABLE_SPRING=1 NODE_OPTIONS=--openssl-legacy-provider rails assets:precompile && \
  bundle config set --local without 'thin test ci aws development build' && \
  bundle install --jobs=4 --retry=3

FROM base AS production
COPY . .
COPY --from=production-builder /app/public ./public
COPY --from=production-builder /app/config ./config
COPY --from=production-builder /usr/local/bundle /usr/local/bundle
EXPOSE 3000
RUN chmod a+x /app/bin/run
CMD [ "/app/bin/run" ]
