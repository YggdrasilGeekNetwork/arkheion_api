# syntax=docker/dockerfile:1
# check=error=true

# docker build -t arkheion_api .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name arkheion_api arkheion_api

ARG RUBY_VERSION=3.4.1
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Runtime dependencies:
# - libpq5        → PostgreSQL client lib
# - libsqlite3-0  → SQLite3 runtime (tormenta20 gem)
# - libjemalloc2  → reduced memory/latency
# - libvips       → Active Storage image processing
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libpq5 libsqlite3-0 libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# ── build stage ────────────────────────────────────────────────────────────────
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential git libpq-dev libsqlite3-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (required by ActiveAdmin)
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# ── final stage ────────────────────────────────────────────────────────────────
FROM base

COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

ENTRYPOINT ["/rails/bin/docker-entrypoint"]

EXPOSE 80
CMD ["./bin/thrust", "./bin/rails", "server"]
