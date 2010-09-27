# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_moip_usage_session',
  :secret      => 'c601382324abdd6a8d75ace39303fe2d3bb7546a2c8dd9f82da47d31a92ca188d357d2594f39518970f96c4b1608fb9785a819e2ebe3fd295a628c4c75e41307'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
