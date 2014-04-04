ENV['RAILS_ENV'] ||= 'test'

require 'active_model'
require 'datapimp'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'rspec/autorun'
require 'machinist/active_record'
require 'faker'
require 'rack/test'
require "pry"

Rails.backtrace_cleaner.remove_silencers!

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.before(:suite) do
    Models.make
  end
end

