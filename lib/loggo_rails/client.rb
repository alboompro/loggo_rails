module LoggoRails
  class Client
    API_URL = 'http://localhost:3579'.freeze

    attr_reader :token

    def initialize
      @token = Rails.configuration.loggo_rails.token
    end

    def insert(options)
      RestClient::Request.execute(
        headers: client_headers,
        method: :put,
        url: insert_url,
        payload: options.to_json,
        verify_ssl: false
      )
    end

    protected

    def client_headers
      {
        'Authorization': token,
        'Content-Type': 'application/json'
      }
    end

    def insert_url
      "#{Rails.configuration.loggo_rails.api_url || API_URL}/insert"
    end
  end
end
