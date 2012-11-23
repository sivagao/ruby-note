
$:.unshift(%{C:/Ruby193/lib/ruby/gems/1.9.1/gems/gaze-0.2/bin})

require "gaze"
require "test/unit"
require "rack/test"

require "pry"
#set : environment, :test
Rack::Test::DEFAULT_HOST = "localhost"

class GazeTest < Test::Unit::TestCase
    include Rack::Test::Methods

    # def setup
    # end

    # def teardown
    # end
    def app
        Sinatra::Application
    end

    def test_it_set_up
        get '/pages/'
        #pry.binding
        assert last_response.ok?
        assert last_response.body?("md")
    end

    def test_it_render_markdown_ok
        get "/"
        follow_redirect!
        assert "http://localhost:4567/pages/", last_request.url
        assert last_response.body.include?("README.md")
    end

end

