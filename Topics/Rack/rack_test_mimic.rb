require "uri"
require "rack"
require "rack/mock_session"
require "rack/test/cookie_jar"
require "rack/test/mock_digest_request"
require "rack/test/utils"
require "rack/test/methods"
require "rack/test/uploaded_file"

module Rack
    module Test
        VERSION = ''

        DEFAULT_HOST = ''
        MUTIPART_BOUNDARY = "-"*7 + "XnJLe9ZIbbGUYtzPQJ16u1"

        class Error < StandardError;end

        # this class represents a series of requests issued to a Rack app, sharing
        # a single cookie jar
        # 
        # methods of this class are most called through Rack::Test::Methods,
        # which will automatically build a session when it is first used
        class Session
            extend Forwardable
            include Rack::Test::utils

            def_delegators :@rack_mock_session, :clear_cookies, :set_cookie, :last_response, :last_request

            # not need to initialize directly, instead you should include Rack::Test::Methods into your testing cotext
            def initalize(mock_session)
                @headers = {}

                if mock_session.is_a?(MockSession)
                    @rack_mock_session = mock_session
                else
                    @rack_mock_session = MockSession.new(mock_session)
                end
                @default_host = @rack_mock_session.default_host
            end

            def get(uri, params = {}, env = {}, &block)
                env = env_for(uri, env.merge(:method => 'GET', :params => params))
                process_request(uri, env, &block)
            end

            def request(uri, env={}, &block)
                env = env_for(uri, env)
                process_request(uri, env, &block)
            end

            # set a headers to be included on all subsequent requests through
            # session. use a value of nil to remove a previously configured header
            # 
            # EXAMPLE:
            # header "User-Agent", "Firefox"
            def header(name, value)
                if value.nil?
                    @headers.delete(name)
                else
                    @headers[name] = value
                end
            end

            def follow_redirect!
                unless last_reponse.redirect?
                    raise Error.new("last response was not a redirect. cant follow_redirect")
                end

                get(last_reponse['Location'], {}, {"HTTP_REFERER" => last_request.url})
            end

            private
                def env_for
                end

                def process_request(uri,env)

                end

                def default_env
                end

                def headers_for_env
                end

                def params_to_string(params)
                    case params
                    when Hash.then build_nested_query(params)
                    when nil then ""
                    else params
                    end
                end


            end

            def self.encoding_aware_strings?
            end

        end
    end
end

# rack/test/methods
module Rack
    module Test
        module Methods
            extend Forwardable

            def rack_mock_session(name = :default)
                return build_rack_mock_session unless name

                @_rack_mock_sessions ||= {}
                @_rack_mock_sessions[name] ||= build_rack_mock_session
            end

            def current_session
                rack_test_session(_current_session_names)
            end

            def _with_session_names
                @_current_session_names ||= [:default]
            end

            METHODS = []

            def_delegators :current_session, *METHODS
        end
    end
end