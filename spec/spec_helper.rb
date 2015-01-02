require 'bundler'
Bundler.setup(:default, :development)

unless RUBY_PLATFORM =~ /java/
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'httpi2'
require 'rspec'

RSpec.configure do |config|
  config.mock_with :mocha
  config.order = 'random'
end

HTTPI2.log = false

require 'support/fixture'
require 'support/matchers'
