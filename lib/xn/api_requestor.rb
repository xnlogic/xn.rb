# Simple API request wrapper.  Instantiate multiple times to hit the
# server in parallel.

module Xn
  class AuthorizationError < StandardError; end

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

    # Calls a method resource to create a vertex and returns a renderable JSON response
    def put(resource_url, body = nil, &block)
      http_put = Net::HTTP::Put.new resource_url, {'Content-Type' =>'application/json'}
      http_put.body = json_body(body) if body
      call_http_server http_put, &block
    end

    # Calls a method resource to update a vertex and returns a renderable JSON response
    def patch(resource_url, body = nil, &block)
      http_patch = Net::HTTP::Put.new resource_url, {'Content-Type' =>'application/json'}
      http_patch.body = json_body(body) if body
      call_http_server http_patch, &block
    end

    private

    # Ensure the body is json
    def json_body(body)
      if body.is_a? Enumerable
        body.to_json
      else
        body
      end
    end

    def call_http_server(request, &block)
      request['AUTHORIZATION'] = token if token
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https' ) do |http|
        response = nil
        t = Thread.new { response = http.request(request) }
        i = 0
        while response.nil?
          i += 1
          print '.'
          if i % 20 == 0
            print "\r"
          end
          sleep 0.01
        end
        print "\r"
        t.join

        begin
          json = JSON.parse(response.body)
          raise AuthorizationError, "#{json['message']} (#{json['parsed_url']})" if response.code.to_i == 401
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
      rescue Exception => e
        raise e if e.is_a? AuthorizationError
        raise e if e.is_a? Errno::ECONNREFUSED or e.is_a? Net::HTTPBadRequest
        puts "ERROR making request from: "
        puts request
        puts e.message
        puts e.backtrace
    end
  end
end

