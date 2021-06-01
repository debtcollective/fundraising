source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}" }

ruby '2.7.2'

# Gems required for running several rails components with RUBY_VERSION >= 2.7
# Mroe info here https://github.com/moove-it/sidekiq-scheduler/issues/298#issuecomment-573451653
if RUBY_VERSION >= '2.7'
  gem 'e2mmap'
  gem 'thwait'
end

gem 'rails', '6.1.3.1'
gem 'rake', '13.0.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '5.3.1'
gem 'sassc', '~> 2.4', '>= 2.4.0'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'redis', '~> 4.0'
gem 'redis-namespace', '1.8.1'
gem 'ffi', '~> 1.9', '>= 1.9.25'
gem 'rack-cors', '1.1.1'
gem 'discourse_api', '0.45.0'
gem 'data_migrate', '7.0.0'
gem 'paper_trail', '12.0.0'

# Validations
gem 'validate_url', '1.0.13'
gem 'valid_email2', '3.6.0'
gem 'date_validator', '0.10.0'

# Emails
gem 'inky-rb', '1.3.8.0', require: 'inky'
gem 'premailer-rails', '1.11.1'
gem 'gibbon', '3.3.4'

# front-end libraries
gem 'react-rails', '2.6.1'
gem 'mini_racer', platforms: :ruby
gem 'country_select', '~> 4.0'
gem 'view_component', '2.30.0', require: "view_component/engine"

# Payments
gem 'stripe', '5.31.0'

# Authentication
gem 'jwt', '~> 2.2.1'
gem 'recaptcha', '~> 5.2', '>= 5.2.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.7.4', require: false

# Background jobs
gem 'sidekiq', '6.2.0'
gem 'sidekiq-scheduler', '3.0.1'

# monitoring
gem 'skylight', '5.0.1'
gem "health_check", github: 'ianheggie/health_check', :ref => '0b799ea'
gem 'sentry-raven', '~> 3.0', '>= 3.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'annotate', '3.1.1'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'cypress-on-rails', '1.9.1'
  gem 'cypress-rails', '0.5.0'
  gem 'dotenv-rails', '2.7.6'
  gem 'factory_bot', '~> 6.2'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 2.1', '>= 2.1.2'
  gem 'guard-rspec', '4.7.3', require: false
  gem 'pry-byebug', '~> 3.9.0'
  gem 'standard', '0.13.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.6'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'solargraph', '0.40.4'
end

group :test do
  gem 'capybara', '~> 3.28'
  gem 'capybara-screenshot', '1.0.25'
  gem 'climate_control', '~> 1.0.1'
  gem 'codecov', '0.4.3', require: false
  gem 'database_cleaner-active_record', '2.0.0'
  gem 'rspec-mocks', '3.10.2'
  gem 'rspec-rails', '5.0.1'
  gem 'selenium-webdriver', '~> 3.142', '>= 3.142.3'
  gem 'shoulda-matchers', '4.5.1'
  gem 'stripe-ruby-mock', '3.0.1', :require => 'stripe_mock'
  gem 'timecop', '~> 0.9.1'
  gem 'vcr', '6.0.0'
  gem 'webdrivers', '4.6.0'
  gem 'webmock', '3.12.2'
end
