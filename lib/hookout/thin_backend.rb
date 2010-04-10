module Hookout
  # Backend allowing Thin to act as a Reverse HTTP server
  class ThinBackend < Thin::Backends::Base
    # Address and port on which the server is listening for connections.
    attr_accessor :server_address, :label
    
    def initialize(server, label, options)
      @server_address = options[:address]
      @label = options[:label]
      
      super()
    end
    
    # Connect the server
    def connect
      @connector = ReverseHttpConnector.new(@label, @server_address, self)
      @connector.report_poll_exceptions = true
      @connector.location_change_callback = lambda { |l| puts "Bound to location #{l}" }
      
      EventMachine.defer do
        @connector.start
      end
    end
    
    # Stops the server
    def disconnect
      @connector.stop
    end
          
    def to_s
      "#{@label} via #{@server_address}"
    end
    
    def handle_request(request)
      connection = ThinConnection.new(request.to_s)
      connection.rhttp_req = request
      connection.backend = self
      initialize_connection(connection)
      
      connection.receive_data(request.body)
    end
  end
  
  class ThinConnection < Thin::Connection
    attr_accessor :rhttp_req
    attr_accessor :backend
    
    def persistent?
      false
    end
    
    def send_data(data)
      @rhttp_req.write(data)
    end
    
    def close_connection_after_writing
      begin
        @rhttp_req.close
      ensure
        @backend.connection_finished(self)
      end
    end
  end
end