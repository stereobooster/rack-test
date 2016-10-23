module Trialday
  class Base
    APPLICATION_JSON = 'application/json'.freeze
    GET = 'GET'.freeze
    POST = 'POST'.freeze
    REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    PATH_INFO = 'PATH_INFO'.freeze
    CONTENT_TYPE = 'CONTENT_TYPE'.freeze

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
      verb = env[REQUEST_METHOD]
      requested_path = env[PATH_INFO]
      media_type = env[CONTENT_TYPE]

      handler = @routes.fetch(verb, {}).fetch(requested_path, nil)

      unless handler
        [NOT_FOUND_CODE, {}, [NOT_FOUND_MESSAGE]]
      end

      unless media_type == APPLICATION_JSON || media_type.nil?
        return [NOT_ACCEPTABLE_CODE, {}, [NOT_ACCEPTABLE_MESSAGE]]
      end

      params = {}
      if env["rack.input"] && (body = env["rack.input"].read).length != 0
        env["rack.input"].rewind
        begin
          params = JSON.parse(body, symbolize_names: true)
          unless params.is_a?(Hash)
            return [BAD_REQUEST_CODE, {}, [BAD_REQUEST_MESSAGE]]
          end
        rescue JSON::ParserError
          return [BAD_REQUEST_CODE, {}, [BAD_REQUEST_MESSAGE]]
        end
      end

      result = JSON.generate(handler.call(params))
      [200, {CONTENT_TYPE => APPLICATION_JSON}, [result]]
    end

    private

      def route(verb, path, &handler)
        @routes[verb] ||= {}
        @routes[verb][path] = handler
      end
  end
end

Trialday::Base.new.tap do |app|
  app.get "/bla" do
    { results: [1, 2, 3] }
  end

  app.post "/bla" do |params|
    name = params[:name] || params['name']
    { name: name }
  end
end
