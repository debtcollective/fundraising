source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}" }

ruby '2.7.1'

# Gems required for running several rails components with RUBY_VERSION >= 2.7
# Mroe info here https://github.com/moove-it/sidekiq-scheduler/issues/298#issuecomment-573451653
if RUBY_VERSION >= '2.7'
  gem 'e2mmap'
  gem 'thwait'
end

gem 'rails', '6.0.3.2'
gem 'rake', '13.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '4.3.5'
gem 'sassc', '~> 2.4', '>= 2.4.0'
gem 'webpacker', '~> 5.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.7'
gem 'redis', '~> 4.0'
gem 'redis-namespace', '1.8'
gem 'ffi', '~> 1.9', '>= 1.9.25'
gem 'valid_email2', '3.3.1'

# Emails
gem 'inky-rb', '1.3.8.0', require: 'inky'
gem 'premailer-rails', '1.11.1'

# front-end libraries
gem 'react_on_rails', '~> 12.0'
gem 'mini_racer', platforms: :ruby

# Payments
gem 'stripe', '5.22.0'

# Authentication
gem 'jwt', '~> 2.2.1'
gem 'recaptcha', '~> 5.2', '>= 5.2.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '1.4.7', require: false

# Background jobs
gem 'sidekiq', '6.1.1'
gem 'sidekiq-scheduler', '3.0.1'

# monitoring
gem 'skylight', '4.3.1'
gem "health_check", github: 'ianheggie/health_check', :ref => '0b799ea'
gem 'sentry-raven', '~> 3.0', '>= 3.0.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-byebug', '~> 3.9.0'
  gem 'standard', '0.4.7'
  gem 'dotenv-rails', '2.7.6'
  gem 'faker', '~> 2.1', '>= 2.1.2'
  gem 'factory_bot', '~> 5.0', '>= 5.0.2'
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.2'
  gem 'annotate', '3.1.1'
  gem 'guard-rspec', '4.7.3', require: false
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.3'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'solargraph', '0.39.13'
end

group :test do
  gem 'climate_control', '~> 0.2.0'
  gem 'capybara', '~> 3.28'
  gem 'capybara-screenshot', '1.0.24'
  gem 'codecov', '0.2.6', require: false
  gem 'database_cleaner-active_record', '1.8.0'
  gem 'rspec-mocks', '3.9.1'
  gem 'rspec-rails', '4.0.1'
  gem 'selenium-webdriver', '~> 3.142', '>= 3.142.3'
  gem 'shoulda-matchers', '~> 4.1', '>= 4.1.2'
  gem 'stripe-ruby-mock', '~> 3.0.0', :require => 'stripe_mock'
  gem 'timecop', '~> 0.9.1'
  gem 'webdrivers', '4.4.1'
end
