module LoggoRails
  class Engine < ::Rails::Engine
    config.loggo_rails = ActiveSupport::OrderedOptions.new


    config.loggo_rails.logger = LoggoRails::Logger.new false
    config.loggo_rails.formatter = LoggoRails::Formatter.new
    config.loggo_rails.api_url = nil
    config.loggo_rails.app_name = 'rails-logs'

    # Replace Rails logger initializer
    Rails::Application::Bootstrap.initializers.delete_if {|i| i.name == :initialize_logger}

    initializer :initialize_logger, group: :all do

      config = Rails.application.config
      config.colorize_logging = false
      config.log_tags = [:request_id, :remote_ip]
      config.loggo_rails.logger.formatter = config.loggo_rails.formatter
      Rails.logger = config.logger = ActiveSupport::TaggedLogging.new config.loggo_rails.logger

      # # Replace Rails loggers
      # [:active_record, :action_controller, :action_mailer, :action_view].each do |name|
      #   ActiveSupport.on_load(name) {include SemanticLogger::Loggable}
      # end
    end

    # Before any initializers run, but after the gems have been loaded
    # config.before_initialize do
    #   # Replace the Sidekiq logger
    #   Sidekiq::Logging.logger = SemanticLogger[Sidekiq]
    #
    #   # Set the logger for concurrent-ruby
    #   Concurrent.global_logger = SemanticLogger[Concurrent] if defined?(Concurrent)
    #
    #   # Rails Patches
    #   # require('rails_semantic_logger/extensions/action_cable/tagged_logger_proxy') if defined?(ActionCable)
    #   # require('rails_semantic_logger/extensions/action_controller/live') if defined?(ActionController::Live)
    #   require('rails_semantic_logger/extensions/action_dispatch/debug_exceptions') if defined?(ActionDispatch::DebugExceptions)
    #   require('rails_semantic_logger/extensions/action_view/streaming_template_renderer') if defined?(ActionView::StreamingTemplateRenderer::Body)
    #   require('rails_semantic_logger/extensions/active_job/logging') if defined?(ActiveJob)
    #   require('rails_semantic_logger/extensions/active_model_serializers/logging') if defined?(ActiveModelSerializers)
    #
    #   # if config.rails_semantic_logger.semantic
    #   require('rails_semantic_logger/extensions/rails/rack/logger') if defined?(Rails::Rack::Logger)
    #   require('rails_semantic_logger/extensions/action_controller/log_subscriber') if defined?(ActionController)
    #   require('rails_semantic_logger/extensions/active_record/log_subscriber') if defined?(ActiveRecord::LogSubscriber)
    #   # end
    #
    #   # unless config.rails_semantic_logger.started
    #   require('rails_semantic_logger/extensions/rails/rack/logger_info_as_debug') if defined?(Rails::Rack::Logger)
    #   # end
    #
    #   # unless config.rails_semantic_logger.rendered
    #   require('rails_semantic_logger/extensions/action_view/log_subscriber') if defined?(ActionView::LogSubscriber)
    #   # end
    #
    #   # if config.rails_semantic_logger.processing
    #   require('rails_semantic_logger/extensions/action_controller/log_subscriber_processing') if defined?(ActionView::LogSubscriber)
    #   # end
    #
    #   # if config.rails_semantic_logger.named_tags && defined?(Rails::Rack::Logger)
    #   Rails::Rack::Logger.named_tags = config.rails_semantic_logger.named_tags
    #   # end
    # end
  end
end
