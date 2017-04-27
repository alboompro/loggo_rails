module LoggoRails
  class Formatter < ::Logger::Formatter

    # [123213-12312-1231-123] [123.123.123.123] body of message
    REGEX_SESSION_IP = /^\[(?<session>[^\]]+)\]\s\[(?<ip>[^\]]+)\]\s(?<content>.+)/m.freeze

    # Started GET "/api/v1/albums" for 127.0.0.1 at 2017-04-26 19:03:33 -0300
    REGEX_STARTED = /Started (?<method>[\S]+) "(?<path>[^"]+)" for (?<ip>[\S]+) at (?<time>.+)/.freeze

    # Processing by Api::V1::AlbumsController#update as JSON
    REGEX_PROCESSING = /Processing by (?<controller>[^\#]+)\#(?<action>\w+) as (?<format>\w+)/.freeze

    # Parameters: {"album"=>{"title"=>"asdsadas", "status"=>"draft", "view_mode"=>"list", "cover"=>""}}
    REGEX_PARAMETERS = /Parameters: (?<parameters>.+)/.freeze

    # Unpermitted parameters: group, slug, autoFocus, focused, oldName
    REGEX_UNPERMITTED_PARAMETERS = /Unpermitted parameters: (?<unpermittedparameters>[\w, ]+)/.freeze

    # SQL (3.5ms)  INSERT INTO `albuns` (`id_cliente`, `titulo`, `url`, `capa`, `status`) VALUES (3, 'asdsadas', 'asdsadas', '', 'draft')
    # Album Load (0.7ms)  SELECT  `albuns`.* FROM `albuns` WHERE `albuns`.`deleted_at` IS NULL AND `albuns`.`id_cliente` = 3 AND `albuns`.`id` = 22898 LIMIT 1
    # Client Load (3.6ms)  SELECT  `clientes`.* FROM `clientes` WHERE `clientes`.`id` = 3 LIMIT 1
    # SQL (4.3ms)  DELETE FROM `categorias` WHERE `categorias`.`id` = 7
    REGEX_SQL = /(SQL|(?<model>[\S]+) [\S]+)\s+\((?<time>[^)]+)\)\s+(?<query>.+)/.freeze

    # Rendered api/v1/categories/show.rabl (1.0ms)
    REGEX_RENDERED = /Rendered (?<view>\S+) \((?<time>[^\)]+)\)/.freeze

    # Rendering api/v1/categories/show.rabl
    REGEX_RENDERING = /Rendering (<view>\S+)/
                        .freeze
    # Completed 201 Created in 65ms (Views: 10.4ms | ActiveRecord: 38.2ms)
    # Completed 404 Not Found in 13ms (Views: 0.2ms | ActiveRecord: 0.8ms)
    # Completed 204 No Content in 172ms (ActiveRecord: 67.1ms)
    REGEX_COMPLETED_FULL = /Completed (?<response>\d+) .+ in (?<time>\S+)(?<details>.+)?/.freeze

    # (Views: 10.4ms | ActiveRecord: 38.2ms)
    # (Views: 0.2ms | ActiveRecord: 0.8ms)
    # (ActiveRecord: 67.1ms)
    REGEX_COMPLETED_VIEWS = /Views: (?<time>[^\s\)]+)/.freeze

    # (Views: 10.4ms | ActiveRecord: 38.2ms)
    # (Views: 0.2ms | ActiveRecord: 0.8ms)
    # (ActiveRecord: 67.1ms)
    REGEX_COMPLETED_ACTIVE_RECORD = /ActiveRecord: (?<time>[^\s\)]+)/.freeze

    attr_reader :sync

    def initialize
      @sync = LoggoRails::Sync.new
    end

    def call(severity, time, progname, msg)
      Thread.new do
        parsed = parse_message msg2str(msg), progname
        return unless parsed
        node, descr, content = parsed
        sync.write(
          app: Rails.configuration.loggo_rails.app_name,
          log: {
            timestamp: time,
            type: severity,
            node: node,
            description: descr,
            content: content
          }
        )
      end
      super
    end

    protected

    def parse_message(msg, progname)
      session, ip, msg = load_session_ip_from msg.strip
      return false unless session
      msg.strip!
      node, match = test_node msg
      content = {
        process_id: $$,
        session: session,
        ip: ip,
        progname: progname,
      }
      match.names.each do |name|
        case name
          when 'details'
            content = completed_details(content, match[name])
          when 'parameters'
            content[name] = proccess_parameters(match[name])
          when 'unpermittedparameters'
            content[:parameters] = proccess_parameters(match[name])
          else
            content[name] = match[name]
        end
      end
      [node, msg.split("\n")[0], content]
    end

    def load_session_ip_from(msg)
      match = REGEX_SESSION_IP.match msg
      if match
        [match[:session], match[:ip], match[:content]]
      else
        [false, false, false]
      end
    end

    def test_node(content)
      nodes = {
        started: REGEX_STARTED,
        processing: REGEX_PROCESSING,
        parameters: REGEX_PARAMETERS,
        unpermitted_parameters: REGEX_UNPERMITTED_PARAMETERS,
        sql: REGEX_SQL,
        render: [REGEX_RENDERED, REGEX_RENDERING],
        completed: REGEX_COMPLETED_FULL
      }

      nodes.each_key do |key|
        if nodes[key].is_a? Array
          nodes[key].each do |rgx|
            match = rgx.match content
            return [key, match] if match
          end
        else
          match = nodes[key].match content
          return [key, match] if match
        end
      end

      [false, false]
    end

    def completed_details(content, match)
      return content if match.blank?
      match.strip!
      nodes = {
        views: REGEX_COMPLETED_VIEWS,
        active_record: REGEX_COMPLETED_ACTIVE_RECORD
      }
      nodes.each_key do |key|
        m = nodes[key].match match
        content[key] = m[:time] if m
      end
      content
    end


    # Convert the log parameters to Hash Object
    #
    # @see https://gist.github.com/gene1wood/bd8159ad90b0799d9436
    #
    # @param str String
    # @return Hash
    def proccess_parameters(str)
      str.strip!
      # Transform object string symbols to quoted strings
      str.gsub!(/([{,]\s*):([^>\s]+)\s*=>/, '\1"\2"=>')

      # Transform object string numbers to quoted strings
      str.gsub!(/([{,]\s*)([0-9]+\.?[0-9]*)\s*=>/, '\1"\2"=>')

      # Transform object value symbols to quotes strings
      str.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>\s*:([^,}\s]+\s*)/, '\1\2=>"\3"')

      # Transform array value symbols to quotes strings
      str.gsub!(/([\[,]\s*):([^,\]\s]+)/, '\1"\2"')

      # Transform object string object value delimiter to colon delimiter
      str.gsub!(/([{,]\s*)(".+?"|[0-9]+\.?[0-9]*)\s*=>/, '\1\2:')

      JSON.parse(str)
    end

    # @param str String
    # @return Array
    def proccess_unpermitted_parameters(str)
      str.split(', ')
    end
  end
end
