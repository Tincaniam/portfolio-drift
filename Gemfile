source "https://rubygems.org"
ruby ">= 3.3.1", "< 4.0"

gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# Rails 8.1 uses the JSON 2.x positional options API for session cookies.
gem "json", "~> 2.0"
gem "propshaft"
gem "pg", "~> 1.6"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tzinfo-data", platforms: %i[windows jruby]

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end
