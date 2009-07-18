require 'thin'

module Hookout
  class RackAdapter
    def initialize(app)
      @app = app
    end
    
    def handle_request(request)
      thin_request = Thin::Request.new
      thin_request.parse request.body

      status,headers,body = @app.call(thin_request.env)

      thin_response = Thin::Response.new
      thin_response.status = status
      thin_response.headers = headers
      thin_response.body = body

      thin_response.each do |chunk|
        request.write(chunk)
      end
    end
  end
end