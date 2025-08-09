#!/usr/bin/env bash
# exit on error
set -o errexit

# Install Ruby dependencies
bundle install

# Install Node.js dependencies (including devDependencies for build tools)
yarn install --frozen-lockfile --production=false || yarn install --production=false

# Precompile assets
bundle exec rails assets:precompile

# Clean old assets
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate