module LoggoRails
  class Sync
    include MonitorMixin

    def initialize()
      mon_initialize
    end

    def write(msg)
      synchronize do
        client.insert msg
      end
    rescue Exception => ignored
      warn("log writing failed. #{ignored}")
    end

    protected

    def client
      @client ||= LoggoRails::Client.new
      @client
    end
  end
end