module LoggoRails
  class Engine < ::Rails::Engine
    config.loggo_rails = ActiveSupport::OrderedOptions.new

    config.loggo_rails.enabled = false
    config.loggo_rails.logger = LoggoRails::Logger.new false
    config.loggo_rails.formatter = LoggoRails::Formatter.new
    config.loggo_rails.api_url = nil
    config.loggo_rails.app_name = 'rails-logs'

    # Replace Rails logger initializer
    default_initializer = nil
    Rails::Application::Bootstrap.initializers.delete_if do |i|
      if i.name == :initialize_logger
        default_initializer = i
        true
      else
        false
      end
    end

    initializer :initialize_logger, group: :all do |*args|
      if config.loggo_rails.enabled
        config = Rails.application.config
        config.colorize_logging = false
        config.log_tags = [:request_id, :remote_ip]
        config.loggo_rails.logger.formatter = config.loggo_rails.formatter
        Rails.logger = config.logger = ActiveSupport::TaggedLogging.new config.loggo_rails.logger
      else
        default_initializer.bind(Rails.application).run(args)
      end
    end

  end
end
