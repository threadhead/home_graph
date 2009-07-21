# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_myffff_session',
  :secret      => '6a0277e7cf797efa81017a9734dca6c21e0e2d7eb52122aa28f07f9f116e3b0643e70bd3fe85c4a1127c0733044a90375791ad4027a3323a3cce8089e09010cd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
