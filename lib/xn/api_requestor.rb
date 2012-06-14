# Simple API request wrapper.  Instantiate multiple times to hit the
# server in parallel.
module Xn
  class ApiRequestor
    attr_accessor :uri, :token

    def initialize(server_uri, token = nil)
      raise "#{self.class} Err: First arg must be an instance of URI" if !server_uri.is_a? URI
      @uri = server_uri
      @token = token
    end

    # Request the resource(s) and a renderable JSON response
    def get(resource_url, &block)
      call_http_server Net::HTTP::Get.new( resource_url ), &block
    end

    # Calls a method resource and returns a renderable JSON response
    def post(resource_url, body = nil, &block)
      http_post = Net::HTTP::Post.new resource_url, {'Content-Type' =>'application/json'}
      if body
        body = body.to_json if body.is_a? Enumerable
        http_post.body = body
      end
      call_http_server http_post, &block
    end

    private

    def call_http_server(request, &block)
      request['AUTHORIZATION'] = token if token
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https' ) do |http|
        response = http.request(request)
        begin
          json = JSON.parse(response.body)
        rescue JSON::ParserError => e
          # Probably not JSON, return entire body
          return { status: response.code.to_i, body: response.body }
        end
        if block and response.code.to_i < 300
          block.call json
        else
          { status: response.code.to_i, json: json }
        end
      end
    end
  end
end

