source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.3"

gem "rails", "~> 7.1.0"
gem "sqlite3", "~> 1.6"
gem "puma", "~> 6.4"
gem "bootsnap", ">= 1.4.4", require: false
gem "rack-cors"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 6.1"
  gem "factory_bot_rails"
  gem "faker"
  gem "rubocop", "~> 1.60", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
end

group :development do
  gem "listen", "~> 3.3"
end

group :test do
  gem "shoulda-matchers", "~> 5.0"
  gem "simplecov", require: false
end
