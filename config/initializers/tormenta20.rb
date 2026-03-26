# Tormenta20.setup is auto-called when the gem is loaded (end of tormenta20.rb).
# It calls ActiveRecord::Base.establish_connection(adapter: 'sqlite3', ...)
# which overrides the app's PostgreSQL connection.
#
# Fix: pin the tormenta20 models to their own SQLite connection pool,
# then restore the app's PostgreSQL connection on ApplicationRecord.

# Ensure Tormenta20 models always resolve through their own abstract base
Tormenta20::Models::Base.establish_connection(
  adapter: "sqlite3",
  database: Tormenta20::Database.db_path,
  pool: 5,
  timeout: 5000
)

# Restore the primary (PostgreSQL) connection for all app models.
# ApplicationRecord inherits from ActiveRecord::Base, so setting it here
# is sufficient — tormenta20 models still use the SQLite pool set above.
ActiveRecord::Base.establish_connection(Rails.env.to_sym)

# Silence SQL query logs from the tormenta20 SQLite connection.
Tormenta20::Models::Base.logger = Logger.new(nil)
