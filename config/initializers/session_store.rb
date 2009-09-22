# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_moip_usage_session',
  :secret      => '0eea16fad425fe07cdb4af83309622923b6b067f6c395d7f3a5c9aa1f7d4994e2d3600b8a03deb268066c5e5b68af25f6bf03048b5033584190eaefe57a10b29'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
