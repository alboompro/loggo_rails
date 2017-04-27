require 'active_support/dependencies/autoload'
require 'rest-client'
require 'json'

module LoggoRails
  include ::ActiveSupport::Autoload

  autoload :Client, 'loggo_rails/client'
  autoload :Formatter, 'loggo_rails/formatter'
  autoload :Logger, 'loggo_rails/logger'
  autoload :Sync, 'loggo_rails/sync'
end

require 'loggo_rails/engine'
