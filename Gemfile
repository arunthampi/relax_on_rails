source 'https://rubygems.org'
ruby '2.2.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails',                    '4.2.5'
# Use postgresql as the database for Active Record
gem 'pg',                       '~> 0.18.2'

# Frontend Stuff
gem 'haml',                     '~> 4.0.7'
gem 'bootstrap-sass',           '~> 3.3.6'
gem 'sass-rails',               '~> 5.0.4'
gem 'autoprefixer-rails',       '~> 6.3.1'

# Relax
gem 'relax-rb',                 '~> 0.1.3', require: 'relax'

# Auth
gem 'devise',                  '~> 3.4.1'
gem 'omniauth-slack',          '~> 2.3.0'

# URL Validation
gem 'validate_url',               github: 'perfectline/validates_url', ref: 'e5374234c218f1871885a03cfb658ae8d484bb4e', require: 'validate_url'

# For Active Record Locking
gem 'with_advisory_lock',     '~> 3.0.0'

# For Job processing
gem 'sidekiq',                    '~> 4.0.1'
gem 'sinatra',                    '~> 1.4.6'
gem 'redis-namespace',            '~> 1.5.2'

# HTTP Client Library
gem 'excon',                  '~> 0.45.4'

group :development do
  # Foreman to launch processes
  gem 'foreman',     '~> 0.70.0'
  # Disables Asset Logging
  gem 'quiet_assets'
end

group :development, :test do
  gem 'rspec-rails',              '~> 3.3.3'
  gem 'rspec-its',                '~> 1.2.0'
end

group :test do
  gem 'database_cleaner',         '~> 1.3.0'
  gem 'factory_girl_rails',       '~> 4.5.0'
  gem 'shoulda-matchers',         '~> 2.8.0'
end

group :production do
  gem 'rails_12factor',           '~> 0.0.3'
end

group :assets do
  gem 'uglifier',                 '~> 2.7.1'
end
