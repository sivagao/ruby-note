
# Using VCR
# https://github.com/myronmarston/vcr
# Recording your test suite's HTTP interactiosn and replay 
# them during future test runs for fast, deterministic, accurate tests. 


Run this test once, and VCR will record the http request to fixtures/vcr_cassettes/synopsis.yml.
 (the response will contain the same headers and body you get from a real request).

require "rubygems"
require "test/unit"
require "vcr"

VCR.config do |c|
    c.cassette_library_dir = "fixtures/vcr_cassettes"
    c.hook_into :webmock
end

class VCRTest < Test::Unit::TestCase
    def test_example_dot_com
        VCR.use_cassette("synopsis") do
            response = Net::HTTP.get_response(URL('http://www.baidu.com'))
            assert_match /Example Domains/, response.body
        end
    end
end




# Using webmock

Features
Stubbing HTTP requests at low http client lib level (no need to change tests when you change HTTP library)
Setting and verifying expectations on HTTP requests
Matching requests based on method, URI, headers and body
Smart matching of the same URIs in different representations (also encoded and non encoded forms)
Smart matching of the same headers in different representations.
Support for Test::Unit
Support for RSpec 1.x and RSpec 2.x
Support for MiniTest

Supported HTTP libraries
Net::HTTP and libraries based on Net::HTTP (i.e RightHttpConnection, REST Client, HTTParty)
HTTPClient
Patron : http client library based on libcurl trying to provide the sane API while taking advantage of libcurl under the hood.
EM-HTTP-Request
Curb (currently only Curb::Easy)
Typhoeus (currently only Typhoeus::Hydra)
Excon

Installation
gem install webmock

adding the following code the test/test_helper.rb
require "webmock/test_unit"

EXAMPLES

stub_request(:any, "www.example.com")
Net::HTTP.get("www.example.com","/") #=> success

stub_request(:post, "www.example.com").with(:body => "abc", :headers => {'Content-Length' => 3})
uri = URI.parse("http://www.example.com")
req = Net::HTTP::POST.new(uri.path)
req['Content-Length'] = 3
res = Net::HTTP.start(uri.host, uri.post) { |http|
    http.request(req, "abc")
}

整体感觉 webmock 非常强大，定制化很强。 对原始的library修改 monkey patch 很多。
stubbing, 
stub_request(:<request method>, "url")
    .with(:body => "xx", :headers => {})
    .to_return()
headers & url, request body matching



stub_http_request(:post, "www.example.com").
        with(:body => hash_including({:data => {:a => '1', :b => 'five'}}))

RestClient.post('www.example.com', "data[a]=1&data[b]=five&x=1", :content_type => 'application/x-www-form-urlencoded')    # ===> Success



Patron
https://github.com/toland/patron
sess = Patron::Session.new
sess.timeout = 10
sess.base_url = "http://myserver.com:8080"
sess.headers["User-Agent"] = 'myapp/1.0'
sess.enable_debug = "/tmp/patron.debug"

resp = sess.get("/foo/bar")
if resp.status < 400
    puts resp.body
end

sess.post("/foo/bar", "some data", {"Content-Type" => "text/plain"})


Libcurl & cURL
Curb - libcurl bindings for Ruby
curb
https://github.com/taf2/curb
Multi Interface (Advanced):
responses = {}
requests = ["http://www.website1.com","http://www.website2.com"]
m = Curl::Multi.new
requests.each do |url|
    responses[url] = ""
    c = Curl::Easy.new(url) do (curl)
        curl.follow_location = true
        curl.onbody {|data| responses[url] << data; data.size}
        curl.onsuccess {|easy| puts "success, add more easy handlers"}
    end
    m.add(c)
end
m.perform do
    puts "idling ... can do some work here"
end

responses.each do |url|
    puts. responses[url]
end

