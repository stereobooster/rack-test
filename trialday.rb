require 'rack'
require 'json'

module Trialday
  class Base
    APPLICATION_JSON = 'application/json'.freeze
    GET = 'GET'.freeze
    POST = 'POST'.freeze
    CONTENT_TYPE = 'Content-Type'.freeze

    # https://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
    NOT_ACCEPTABLE_CODE = 406
    NOT_ACCEPTABLE_MESSAGE = 'Not Acceptable'.freeze
    BAD_REQUEST_CODE = 400
    BAD_REQUEST_MESSAGE = 'Bad Request'.freeze
    NOT_FOUND_CODE = 404
    NOT_FOUND_MESSAGE = 'Not Found'.freeze

    def initialize
      @routes = {}
    end

    def get(path, &handler)
      route(GET, path, &handler)
    end

    def post(path, &handler)
      route(POST, path, &handler)
    end

    def call(env)
      request = Rack::Request.new(env)

      verb = request.request_method
      requested_path = request.path_info

      handler = @routes.fetch(verb, {}).fetch(requested_path, nil)

      unless handler
        [NOT_FOUND_CODE, {}, [NOT_FOUND_MESSAGE]]
      end

      unless request.media_type == APPLICATION_JSON || request.media_type.nil?
        return [NOT_ACCEPTABLE_CODE, {}, [NOT_ACCEPTABLE_MESSAGE]]
      end

      params = {}
      if (body = request.body.read).length != 0
        request.body.rewind
        begin
          params = JSON.parse(body, symbolize_names: true)
          unless params.is_a?(Hash)
            return [BAD_REQUEST_CODE, {}, [BAD_REQUEST_MESSAGE]]
          end
        rescue JSON::ParserError
          return [BAD_REQUEST_CODE, {}, [BAD_REQUEST_MESSAGE]]
        end
      end

      result = JSON.fast_generate(handler.call(params))
      [200, {CONTENT_TYPE => APPLICATION_JSON}, [result]]
    end

    private

      def route(verb, path, &handler)
        @routes[verb] ||= {}
        @routes[verb][path] = handler
      end
  end

  Application = Base.new

  module Delegator
    def self.delegate(*methods, to:)
      Array(methods).each do |method_name|
        define_method(method_name) do |*args, &block|
          to.send(method_name, *args, &block)
        end

        private method_name
      end
    end

    delegate :get, :post, to: Application
  end
end

include Trialday::Delegator

