FROM ruby:3.2.5-slim AS base

WORKDIR /app

# Install necessary dependencies
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg2 && \
    curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    libpq-dev \
    wkhtmltopdf \
    imagemagick \
    tzdata \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-kacst \
    fonts-freefont-ttf \
    libxss1 \
    yarn \
    google-chrome-stable && \
    ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    ln -sf /usr/bin/wkhtmltopdf /usr/local/bin/wkhtmltopdf && \
    chmod +x /usr/local/bin/wkhtmltopdf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add and set up dumb-init
ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

# Environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    GROVER_NO_SANDBOX=true

# Set entrypoint
ENTRYPOINT ["dumb-init", "--"]

FROM base AS dev
COPY . .
ARG NODE_MAJOR=20
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
  apt update -y && apt install -y \
    git \
    nodejs && \
  bundle config set --local without 'mysql' && \
  bundle install && \
  yarn install && yarn --cwd app/javascript/dmp_opidor_react install

FROM dev AS production-builder
ARG DB_ADAPTER \
  DB_USERNAME \
  DB_PASSWORD
RUN bin/docker ${DB_ADAPTER:-postgres} && \
  RAILS_ENV=build DISABLE_SPRING=1 NODE_OPTIONS=--openssl-legacy-provider rails assets:precompile && \
  rm -rf node_modules && \
  bundle config set --local without 'mysql thin test ci aws development build' && \
  bundle install
RUN mkdir -p .ssl && \
    openssl req -new -newkey rsa:2048 -sha1 -subj "/CN=`hostname`" -days 730 -nodes -x509 -keyout ./.ssl/cert.key -out ./.ssl/cert.crt

FROM base AS production
COPY . .
COPY --from=production-builder /app/public ./public
COPY --from=production-builder /app/config ./config
COPY --from=production-builder /usr/local/bundle /usr/local/bundle
COPY --from=production-builder /app/.ssl ./.ssl
EXPOSE 3000
RUN chmod a+x /app/bin/prod
CMD [ "/app/bin/prod" ]
