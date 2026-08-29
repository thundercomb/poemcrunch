# Puma configuration.
# Tunable via env vars so the same config works locally and on Heroku.

max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", max_threads))
threads min_threads, max_threads

workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
preload_app!

port ENV.fetch("PORT", 5000)
environment ENV.fetch("RACK_ENV", "development")
