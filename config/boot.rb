ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# override rails default port
require 'rails/commands/server'

module DefaultOptions
  def default_options
    super.merge!(Port: 3788)
  end
end

Rails::Server.send(:prepend, DefaultOptions)
