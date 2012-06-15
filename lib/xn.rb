if RUBY_VERSION == '1.8.7'
  STDERR.puts <<WARNING
WARNING: XnApiSession is developed using Ruby in 1.9.3 mode.
We recommend you use ruby-1.9.3 or if using JRuby, start ruby in 1.9 mode,
  either with the --1.9 flag, or by setting the environment variable
  JRUBY_OPTS=--1.9
WARNING
end

require 'json'
require 'net/http'
raise "Missing Net::HTTP::Patch in #{RUBY_VERSION}" unless defined? Net::HTTP::Patch

require File.join(File.dirname(__FILE__), 'xn', 'api_requestor')

module Xn
  class XnApiSession
    if RUBY_PLATFORM == 'java'
      require 'java'
      include_class 'java.lang.System'
      include_class 'java.io.Console'
    else
      require 'highline/import'
    end

    # Could make these configurable via xn.yml file in the future:
    attr_reader :url, :login_path, :user, :api_suffix
    attr_accessor :api

    def initialize(server_url, user_email, api_suffix = "v1")
      @url = URI(server_url)
      @login_path = '/sessions.json'
      @user = user_email
      @api_suffix = api_suffix
      @api = ApiRequestor.new url

      if ENV['LMTOKEN']
        @token = ENV['LMTOKEN']
        puts "Using token from env LMTOKEN"
      else
        @token = token
      end
      @api.token = @token
    end

    # Get a user's password from the command line
    # don't cache me...
    def password
      if RUBY_PLATFORM == 'java'
        console = System.console
        pass = console.read_password("Password: ")
        java.lang.String.new(pass)
      else
        pass = ask("Password: "){ |q| q.echo = "*" }
      end
    end

    # Login to the host and prompt for password.
    # return the token
    def login
      request_hash = { user: { email: user, password: password } }
      api.post login_path, request_hash do |response|
        response['token']
      end
    end

    def token
      @token ||= login
    end

    # Fetch a single vertex of given model type from the server
    # return a hash of the vertex or nil
    def find_vertex_by_model(model, filter_string)
      debug "find_vertex_by_model(#{model}, #{filter_string})"
      raise "model is a required argument" if model.nil?
      if filter_string and filter_string[/\?/]
        filer_string += "&limit=1"
      else
        filter_string = "#{filter_string}?limit=1"
      end
      request_path = "/#{api_suffix}/model/#{model.downcase}/#{filter_string}"
      api.get request_path do |response|
        vertex = response.first
        debug "found vertex #{vertex}"
        vertex
      end
    end

    # Fetch a single vertex of given part type from the server
    # return a hash of the vertex or nil
    def find_vertex_by_part(part, filter_string)
      debug "find_vertex_by_part(#{part}, #{filter_string})"
      raise "part is a required argument" if part.nil?
      if filter_string and filter_string[/\?/]
        filer_string += "&limit=1"
      else
        filter_string = "#{filter_string}?limit=1"
      end
      request_path = "/#{api_suffix}/is/#{part.downcase}/#{filter_string}"
      api.get request_path do |response|
        vertex = response.first
        debug "found vertex #{vertex}"
        vertex
      end
    end

    # Create a vertex of given model with given properties
    # return a hash of the vertex or nil
    def create_vertex(model, props)
      debug "create_vertex(#{model}, #{props})"
      raise "model and :name property are required" if model.nil? or props.nil? or props[:name].nil?

      request_path = "/#{api_suffix}/model/#{model.downcase}"
      api.put request_path, props do |response|
        #TODO: DKC 12/6/2012 check that we were authorized to do that! Fail if not?
        if response and response[0] != false
          vertex = response[2]
        end
      end
    end

    # find or create a vertex by model and name and optionally provide
    # a filter string to append to the model/xxx/ URL and properties to set
    # if not found.
    #
    # (example filter_string: 'filter/name/?name[value]=myname')
    def find_or_create_by_model_and_name(model, name, filter_string = nil, props = {})
      debug "find_or_create_by_model_and_name(#{model}, #{name}, #{filter_string}, #{props})"
      filter_string = "filter/name/?name[value]=#{name}" unless filter_string
      props = props.merge name: name
      obj = find_vertex_by_model(model, filter_string)
      if obj.nil? or obj.empty?
        debug "about to create a #{model} vertex with #{props} properties" if obj.nil? or obj.empty?
        obj = create_vertex(model, props)
      end
      obj
    end

    # return all vertices related to the given one
    def related_vertices(vertex)
      debug "related_vertices(#{vertex})"
      if vertex and vertex.is_a? Hash and vertex['meta']['model_name']
        model = vertex['meta']['model_name']
        request_path = "/#{api_suffix}/model/#{model}/#{vertex['id']}/rel"
        req = Net::HTTP::Get.new(request_path)
        req['Authorization'] = token
        result = Net::HTTP.start(host, port) { |http| http.request(req) }
        parts = JSON.parse result.body

        related = parts.map do |part|
          find_vertex_by_model model, "#{vertex['id']}/rel/#{part}"
        end
        debug "found related: #{related}"
        related if related.any?
      end
    end

    protected

    def debug(message = "")
      if ENV['XN_VERBOSITY'] and ENV['XN_VERBOSITY'] == 'debug'
        message = yield if block_given?
        STDERR.puts "DEBUG: #{message}"
      end
    end

    def verbose(message)
      if ENV['XN_VERBOSITY']
        message = yield if block_given?
        STDERR.puts "#{message}"
      end
    end
  end
end

