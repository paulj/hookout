module Rack
  module Handler
    # Rack Handler stricly to be able to use Hookout through the rackup command.
    # To do so, simply require 'hookout' in your Rack config file and run like this
    #
    #   rackup --server hookout
    #
    class Hookout
      def self.run(app, options={})
        # Determine our host
        host = options[:Host] || 'http://localhost:8000/reversehttp'
        host = 'http://localhost:8000/reversehttp' if host[0..3].downcase != 'http'
        
        # Determine our label
        label = options[:Port] || 'ruby'
        label = 'ruby' if label.to_i != 0
        
        server = ::Hookout::ReverseHttpConnector.new(
          label, 
          host,
          ::Hookout::RackAdapter.new(app))
        server.report_poll_exceptions = options[:report_poll_exceptions] || true  # false
        server.location_change_callback = lambda {|l| puts "Location changed to #{l}"} # if options[:log_location_change]
          
        yield server if block_given?
        server.start
      end
    end
    
    register 'hookout', 'Rack::Handler::Hookout'
  end
end