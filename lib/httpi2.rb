require "httpi2/version"
require "httpi2/logger"
require "httpi2/request"
require "httpi2/query_builder"

require "httpi2/adapter/httpclient"
require "httpi2/adapter/curb"
require "httpi2/adapter/excon"
require "httpi2/adapter/net_http"
require "httpi2/adapter/net_http_persistent"
require "httpi2/adapter/em_http"
require "httpi2/adapter/rack"

# = HTTPI2
#
# Executes HTTP requests using a predefined adapter.
# All request methods accept an <tt>HTTPI2::Request</tt> and an optional adapter.
# They may also offer shortcut methods for executing basic requests.
# Also they all return an <tt>HTTPI2::Response</tt>.
#
# == GET
#
#   request = HTTPI2::Request.new("http://example.com")
#   HTTPI2.get(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI2.get("http://example.com", :curb)
#
# == POST
#
#   request = HTTPI2::Request.new
#   request.url = "http://example.com"
#   request.body = "<some>xml</some>"
#
#   HTTPI2.post(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI2.post("http://example.com", "<some>xml</some>", :curb)
#
# == HEAD
#
#   request = HTTPI2::Request.new("http://example.com")
#   HTTPI2.head(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI2.head("http://example.com", :curb)
#
# == PUT
#
#   request = HTTPI2::Request.new
#   request.url = "http://example.com"
#   request.body = "<some>xml</some>"
#
#   HTTPI2.put(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI2.put("http://example.com", "<some>xml</some>", :curb)
#
# == DELETE
#
#   request = HTTPI2::Request.new("http://example.com")
#   HTTPI2.delete(request, :httpclient)
#
# === Shortcuts
#
#   HTTPI2.delete("http://example.com", :curb)
#
# == More control
#
# If you need more control over your request, you can access the HTTP client
# instance represented by your adapter in a block.
#
#   HTTPI2.get request do |http|
#     http.follow_redirect_count = 3  # HTTPClient example
#   end
module HTTPI2

  REQUEST_METHODS = [:get, :post, :head, :put, :delete]

  DEFAULT_LOG_LEVEL = :debug

  class Error < StandardError; end
  class TimeoutError < Error; end
  class NotSupportedError < Error; end
  class NotImplementedError < Error; end

  module ConnectionError; end

  class SSLError < Error
    def initialize(message = nil, original = $!)
      super(message || original.message)
      @original = original
    end
    attr_reader :original
  end

  class << self

    def query_builder
      @query_builder || HTTPI2::QueryBuilder::Flat
    end

    def query_builder=(builder)
      if builder.is_a?(Symbol)
        builder_name = builder.to_s.capitalize
        begin
          builder = HTTPI2::QueryBuilder.const_get(builder_name)
        rescue NameError
          raise ArgumentError, "Invalid builder. Available builders are: [:flat, :nested]"
        end
      end
      unless builder.respond_to?(:build)
        raise ArgumentError, "Query builder object should respond to build method"
      end
      @query_builder = builder
    end

    # Executes an HTTP GET request.
    def get(request, adapter = nil, &block)
      request = Request.new(request) if request.kind_of? String
      request(:get, request, adapter, &block)
    end

    # Executes an HTTP POST request.
    def post(*args, &block)
      request, adapter = request_and_adapter_from(args)
      request(:post, request, adapter, &block)
    end

    # Executes an HTTP HEAD request.
    def head(request, adapter = nil, &block)
      request = Request.new(request) if request.kind_of? String
      request(:head, request, adapter, &block)
    end

    # Executes an HTTP PUT request.
    def put(*args, &block)
      request, adapter = request_and_adapter_from(args)
      request(:put, request, adapter, &block)
    end

    # Executes an HTTP DELETE request.
    def delete(request, adapter = nil, &block)
      request = Request.new(request) if request.kind_of? String
      request(:delete, request, adapter, &block)
    end

    # Executes an HTTP request for the given +method+.
    def request(method, request, adapter = nil)
      adapter_class = load_adapter(adapter, request)

      yield adapter_class.client if block_given?
      log_request(method, request, Adapter.identify(adapter_class.class))

      response = adapter_class.request(method)

      if response &&  HTTPI2::Response::RedirectResponseCodes.member?(response.code) && request.follow_redirect?
        log("Following redirect: '#{response.headers['location']}'.")
        request.url = response.headers['location']
        return request(method, request, adapter)
      end

      response
    end

    # Shortcut for setting the default adapter to use.
    def adapter=(adapter)
      Adapter.use = adapter
    end

    private

    def request_and_adapter_from(args)
      return args if args[0].kind_of? Request
      [Request.new(:url => args[0], :body => args[1]), args[2]]
    end

    def load_adapter(adapter, request)
      Adapter.load(adapter).new(request)
    end

  end
end
