#!/usr/bin/env bash

# Exit on error
set -o errexit

bundle install

# API-only app — no assets to precompile

bin/rails db:migrate
bin/rails db:seed
