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

  end
end

