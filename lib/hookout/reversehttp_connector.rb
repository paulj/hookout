require 'net/http'
require 'cgi'

module Hookout
  class ReverseHttpConnector
    DEFAULT_SERVER = 'http://localhost:8000/reversehttp'
    DEFAULT_LABEL = 'ruby'
    
    attr_accessor :failure_delay, :lease_seconds, :report_poll_exceptions, :location_change_callback
  
    def initialize(label, server_address, handler)
      @label = label
      @server_address = server_address
      @handler = handler
    
      @next_req = nil
      @location = nil
      @failure_delay = 2
      @token = '-'
      @lease_seconds = 30
      @report_poll_exceptions = false
      @location_change_callback = nil
      @closed = false
      @requestor = Hookout::Utils.new
    end
  
    def start
      until @closed
        begin
          (request, client) = next_request()
          unless request.nil?
            @handler.handle_request(request)
            request.close
          end
        rescue
          puts $!
          puts $@
        end
      end
    end
    
    def stop
      @closed = true
      @requestor.abort
    end
  
    def next_request
      until @closed
        declare_mode = (@next_req == nil)
        begin
          response = nil
          if declare_mode
            response = @requestor.post_form @server_address, {:name => @label, :token => @token}
          else
            response = @requestor.get @next_req
          end
          
          return nil if response.nil?
      
          @failure_delay = 2
          if declare_mode
            link_headers = parse_link_headers(response)
            
            @next_req = link_headers['first']
            location_text = link_headers['related']
            if location_text
              @location = location_text
              on_location_changed()
            end
          elsif response['Requesting-Client']
            client_addr = response['Requesting-Client'].split(":")
            this_req = @next_req
            @next_req = parse_link_headers(response)['next']
            return [ReverseHttpRequest.new(this_req, @server_address, response.body), client_addr]
          end
        rescue
          if @report_poll_exceptions
            report_poll_exception
          end
          sleep(@failure_delay)  unless @closed
          
          if @failure_delay < 30
            @failure_delay = @failure_delay * 2
          end
        end
      end
    end
  
    private
      def urlencode(hash)
        hash.each { |k, v| "#{CGI.escape(k)}=#{CGI.escape(v)}" }.join("&")
      end
    
      def parse_link_headers(resp)
        result = {}
        resp['Link'].split(", ").each do |link_header|
          url, rel = nil, nil
        
          link_header.split(";").each do |piece|
            piece = piece.strip
          
            if piece[0..0] == '<':
              url = piece[1..-2]
            elsif piece[0..4].downcase == 'rel="':
              rel = piece[5..-2]
            end
          end

          if url and rel
            result[rel] = url
          end
        end
      
        result
      end
      
      def handle_error(request, client_address)
        if not request.closed:
          begin
              request.write("HTTP/1.0 500 Internal Server Error\r\n\r\n")
              request.close()
          rescue
          end
        end
      end

      def report_poll_exception
        puts $!
        puts $@
      end

      def on_location_changed
        if @location_change_callback
          @location_change_callback.call(@location)
        end
      end
  end

  class ReverseHttpRequest
    attr_reader :body, :server_address
  
    def initialize(reply_url, server_address, body)
      @reply_url = reply_url
      @server_address = server_address
      @body = body
      @response_buffer = StringIO.new
      @closed = false
    end

    def makefile(mode, bufsize)
      if mode[0] == 'r':
        StringIO.new(@body)
      elsif mode[0] == 'w':
        self
      end
    end

    def write(x)
      @response_buffer.write(x)
    end

    def flush
    end
  
    def close
      if not @closed
        @response_buffer.flush
        resp_body = @response_buffer.string

        Hookout::Utils.post_data @reply_url, resp_body
        @closed = true
      end
    end
  end
  
  class Utils
    def initialize
      @current_http = nil
      @current_thread = nil
    end
    
    def get(url)
      parts = URI.parse(url)
      req = Net::HTTP::Get.new(parts.path)
      execute_request(parts, req)
    end

    def post_form(url, params)
      parts = URI.parse(url)
      req = Net::HTTP::Post.new(parts.path)
      req.set_form_data(params)
      execute_request(parts, req)
    end
    
    def abort
      @current_http.finish if @current_http
      @current_thread.raise ConnectorAbortException.new if @current_thread
    end
    
    def execute_request(parts, req)
      begin
        Net::HTTP.start(parts.host, parts.port) {|http|
          @current_http = http
          @current_thread = Thread.current
          http.request(req)
        }
      rescue ConnectorAbortException
        return nil
      ensure
        @current_http = nil
        @current_thread = nil
      end
    end
    
    def self.post_data(url, data)
      parts = URI.parse(url)
      req = Net::HTTP::Post.new(parts.path)
      req.body = data
      req.content_type = 'message/http'
      Net::HTTP.start(parts.host, parts.port) {|http|
        http.request(req)
      }
    end
    
    class ConnectorAbortException < Exception
    end
  end
end